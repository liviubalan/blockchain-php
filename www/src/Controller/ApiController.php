<?php

namespace App\Controller;

use App\Classes\Blockchain;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;

class ApiController extends AbstractController {
    public function test()
    {
        $bitcoin = new Blockchain();

        $bitcoin->createNewBlock(1, 'hash-0', 'hash-1');

        $bitcoin->createNewTransaction(100, 'sender-1', 'recipient-1');
        $bitcoin->createNewBlock(2, 'hash-1', 'hash-2'); // mine a new block

        $bitcoin->createNewTransaction(50, 'sender-2', 'recipient-2');
        $bitcoin->createNewTransaction(300, 'sender-3', 'recipient-3');
        $bitcoin->createNewTransaction(2000, 'sender-4', 'recipient-4');
//        $bitcoin->createNewBlock(3, 'hash-2', 'hash-3'); // mine a new block

        return new JsonResponse($bitcoin);
    }
}
