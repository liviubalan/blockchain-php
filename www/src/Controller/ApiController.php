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
        $this->cache = $container->get('cache.app');

        $cachedBitcoin = $this->cache->getItem(static::CACHE_KEY);
        if ($cachedBitcoin->isHit()) {
            $bitcoin = unserialize($cachedBitcoin->get());
        } else {
            $bitcoin = new Blockchain();
        }
        $this->bitcoin = $bitcoin;

        return parent::setContainer($container);
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
