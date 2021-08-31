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
        $bitcoin->createNewBlock(2, 'hash-1', 'hash-2');
        $bitcoin->createNewBlock(3, 'hash-2', 'hash-3');

        return new JsonResponse($bitcoin->getLastBlock());
    }
}
