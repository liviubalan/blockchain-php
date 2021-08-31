<?php

namespace App\Controller;

use App\Classes\Blockchain;
use Psr\Container\ContainerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Cache\Adapter\AbstractAdapter;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;

class ApiController extends AbstractController
{
    const CACHE_KEY = 'bitcoin';

    private Blockchain $bitcoin;

    /**
     * @var AbstractAdapter
     */
    private $cache;

    public function setContainer(ContainerInterface $container): ?ContainerInterface
    {
        $result = parent::setContainer($container);
        $this->cache = $container->get('cache.app');

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
        $content = trim($request->getContent());
        if (!$content) {
            throw $this->createNotFoundException('Empty request');
        }

        $content = json_decode($content, true);
        if (
            !array_key_exists('amount', $content)
            || !array_key_exists('sender', $content)
            || !array_key_exists('recipient', $content)
        ) {
            throw $this->createNotFoundException('The following fields are mandatory: amount, sender, recipient.');
        }

        $amount = (float) $content['amount'];
        $sender = $content['sender'];
        $recipient = $content['recipient'];

        $blockIndex = $this->bitcoin->createNewTransaction($amount, $sender, $recipient);

        return new JsonResponse("Transaction will be added in block $blockIndex.");
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

        $nodeAddress = $_SERVER['HTTP_HOST'];
        $this->bitcoin->createNewTransaction(12.5, "00", $nodeAddress); // Reward for mining the block

        $newBlock = $this->bitcoin->createNewBlock($nonce, $previousBlockHash, $blockHash);

        return new JsonResponse([
            'note' => "New block mined successfully",
            'block' => $newBlock,
        ]);
    }

    public function registerNode(Request $request): JsonResponse
    {
        $content = trim($request->getContent());
        if (!$content) {
            throw $this->createNotFoundException('Empty request');
        }

        $content = json_decode($content, true);
        if (!array_key_exists('newNodeUrl', $content)) {
            throw $this->createNotFoundException('The following fields are mandatory: newNodeUrl.');
        }

        $newNodeUrl = $content['newNodeUrl'];
        $nodeNotAlreadyPresent = !in_array($newNodeUrl, $this->bitcoin->networkNodes);
        $notCurrentNode = $this->bitcoin->currentNodeUrl !== $newNodeUrl;
        if ($nodeNotAlreadyPresent && $notCurrentNode) {
            $this->bitcoin->networkNodes[] = $newNodeUrl;
        }

        return new JsonResponse([
            'note' => 'New node registered successfully.',
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
