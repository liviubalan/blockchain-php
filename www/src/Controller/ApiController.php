<?php

namespace App\Controller;

use App\Classes\Blockchain;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;

class ApiController extends AbstractController {
    public function test()
    {
        $bitcoin = new Blockchain();

        $previousBlockHash = 'hash-1';
        $currentBlockData = [
            [
                'amount' => 10,
                'sender' => 'sender-1',
                'recipient' => 'recipient-1',
            ],
            [
                'amount' => 30,
                'sender' => 'sender-2',
                'recipient' => 'recipient-2',
            ],
            [
                'amount' => 200,
                'sender' => 'sender-3',
                'recipient' => 'recipient-3',
            ],
        ];
        $nonce = 100;

        var_dump($bitcoin->hashBlock($previousBlockHash, $currentBlockData, $nonce));
        die;

        return new JsonResponse($bitcoin);
    }
}
