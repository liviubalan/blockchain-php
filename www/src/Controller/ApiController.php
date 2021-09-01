<?php

namespace App\Controller;

use App\Classes\Blockchain;
use App\Service\HttpClientService;
use App\Service\ValidatorService;
use Psr\Container\ContainerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Cache\Adapter\AbstractAdapter;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;

class ApiController extends AbstractController
{
    const CACHE_KEY = 'bitcoin';

    private Blockchain $bitcoin;

    private AbstractAdapter $cache;

    private ValidatorService $validator;

    private HttpClientService $httpClient;

    public function setContainer(ContainerInterface $container): ?ContainerInterface
    {
        $result = parent::setContainer($container);
        $this->cache = $container->get('cache.app');
        $this->validator = $container->get(ValidatorService::class);
        $this->httpClient = $container->get(HttpClientService::class);

        $cachedBitcoin = $this->cache->getItem(static::CACHE_KEY);
        if ($cachedBitcoin->isHit()) {
            $bitcoin = unserialize($cachedBitcoin->get());
        } else {
            $server = $this->container->get('request_stack')->getCurrentRequest()->server;
            $scheme = $server->get('REQUEST_SCHEME', '');
            $host = $server->get('HTTP_HOST', '');
            $currentNodeUrl = $scheme.'://'.$host;
            $bitcoin = new Blockchain($currentNodeUrl);
        }
        $this->bitcoin = $bitcoin;

        return $result;
    }

    public function blockchain(): JsonResponse
    {
        return new JsonResponse($this->bitcoin);
    }

    public function transaction(Request $request): JsonResponse
    {
        $this->validator->checkMandatoryFields($request, [
            'amount',
            'sender',
            'recipient',
        ]);

        $newTransaction = json_decode($request->getContent(), true);
        $blockIndex = $this->bitcoin->addTransactionToPendingTransactions($newTransaction);

        return new JsonResponse("Transaction will be added in block $blockIndex.");
    }

    public function transactionBroadcast(Request $request): JsonResponse
    {
        $this->validator->checkMandatoryFields($request, [
            'amount',
            'sender',
            'recipient',
        ]);

        $content = json_decode($request->getContent(), true);
        $amount = (float) $content['amount'];
        $sender = $content['sender'];
        $recipient = $content['recipient'];

        $newTransaction = $this->bitcoin->createNewTransaction($amount, $sender, $recipient);
        $this->bitcoin->addTransactionToPendingTransactions($newTransaction);
        $this->httpClient->broadcast(
            $this->bitcoin->networkNodes,
            $this->get('router')->generate('transaction'),
            $newTransaction
        );

        return new JsonResponse('Transaction created and broadcast successfully.');
    }

    public function receiveNewBlock(Request $request): JsonResponse
    {
        $this->validator->checkMandatoryFields($request, [
            'index',
            'timestamp',
            'transactions',
            'nonce',
            'hash',
            'previousBlockHash',
        ]);

        $newBlock = json_decode($request->getContent(), true);
        $lastBlock = $this->bitcoin->getLastBlock();
        $correctHash = $lastBlock['hash'] === $newBlock['previousBlockHash'];
        $correctIndex = $lastBlock['index'] + 1 === $newBlock['index'];

        if ($correctHash && $correctIndex) {
            $this->bitcoin->chain[] = $newBlock;
            $this->bitcoin->pendingTransactions = [];

            return new JsonResponse([
                'note' => 'New block received and accepted.',
                'newBlock' => $newBlock,
            ]);
        }

        return new JsonResponse([
            'note' => 'New block rejected.',
            'newBlock' => $newBlock,
        ]);
    }

    public function mine(): JsonResponse
    {
        $lastBlock = $this->bitcoin->getLastBlock();
        $previousBlockHash = $lastBlock['hash'];
        $currentBlockData = [
            'transactions' => $this->bitcoin->pendingTransactions,
            'index' => $lastBlock['index'] + 1,
        ];
        $nonce = $this->bitcoin->proofOfWork($previousBlockHash, $currentBlockData);
        $blockHash = $this->bitcoin->hashBlock($previousBlockHash, $currentBlockData, $nonce);
        $newBlock = $this->bitcoin->createNewBlock($nonce, $previousBlockHash, $blockHash);

        $this->httpClient->broadcast(
            $this->bitcoin->networkNodes,
            $this->get('router')->generate('receive_new_block'),
            $newBlock
        );

        // Reward for mining the block
        // This method is not called using HTTP in order to avoid overwriting "bitcoin" cache property
        $nodeAddress = $_SERVER['HTTP_HOST'];
        $content = json_encode([
            'amount' => 12.5,
            'sender' => '00',
            'recipient' => $nodeAddress,
        ]);
        $request = new Request([], [], [], [], [], [], $content);
        $this->transactionBroadcast($request);

        return new JsonResponse([
            'note' => 'New block mined & broadcast successfully.',
            'block' => $newBlock,
        ]);
    }

    public function registerNode(Request $request): JsonResponse
    {
        $this->validator->checkMandatoryFields($request, [
            'newNodeUrl',
        ]);

        $content = json_decode($request->getContent(), true);
        $newNodeUrl = $content['newNodeUrl'];
        $nodeAlreadyPresent = in_array($newNodeUrl, $this->bitcoin->networkNodes);
        $isCurrentNode = $this->bitcoin->currentNodeUrl === $newNodeUrl;
        if (!$nodeAlreadyPresent && !$isCurrentNode) {
            $this->bitcoin->networkNodes[] = $newNodeUrl;
        }

        return new JsonResponse([
            'note' => 'New node registered successfully.',
        ]);
    }

    public function registerNodesBulk(Request $request): JsonResponse
    {
        $this->validator->checkMandatoryFields($request, [
            'allNetworkNodes',
        ]);

        $content = json_decode($request->getContent(), true);
        $allNetworkNodes = $content['allNetworkNodes'];
        foreach ($allNetworkNodes as $networkNodeUrl) {
            $nodeAlreadyPresent = in_array($networkNodeUrl, $this->bitcoin->networkNodes);
            $currentNode = $this->bitcoin->currentNodeUrl === $networkNodeUrl;
            if (!$nodeAlreadyPresent && !$currentNode) {
                $this->bitcoin->networkNodes[] = $networkNodeUrl;
            }
        }

        return new JsonResponse([
            'note' => 'Bulk registration successful.',
        ]);
    }

    public function registerAndBroadcastNode(Request $request): JsonResponse
    {
        $this->validator->checkMandatoryFields($request, [
            'newNodeUrl',
        ]);

        $content = json_decode($request->getContent(), true);
        $newNodeUrl = $content['newNodeUrl'];

        if (!in_array($newNodeUrl, $this->bitcoin->networkNodes)) {
            $this->bitcoin->networkNodes[] = $newNodeUrl;
        }

        $this->httpClient->broadcast(
            $this->bitcoin->networkNodes,
            $this->get('router')->generate('register_node'),
            [
                'newNodeUrl' => $newNodeUrl,
            ]
        );

        $url = $newNodeUrl.$this->get('router')->generate('register_nodes_bulk');
        $allNetworkNodes = array_merge($this->bitcoin->networkNodes, [$this->bitcoin->currentNodeUrl]);
        $this->httpClient->makePost($url, [
            'allNetworkNodes' => $allNetworkNodes,
        ]);

        return new JsonResponse([
            'note' => 'New node registered with network successfully.',
        ]);
    }

    public function test()
    {
        return new JsonResponse('Test endpoint');
    }

    public function __destruct()
    {
        $cachedBitcoin = $this->cache->getItem(static::CACHE_KEY);
        $serializedBitcoin = serialize($this->bitcoin);
        $cachedBitcoin->set($serializedBitcoin);
        $this->cache->save($cachedBitcoin);
    }
}
