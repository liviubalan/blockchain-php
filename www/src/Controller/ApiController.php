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

        $message = 'test';
        echo 'md5: '.md5($message)."\n";
        echo 'sha1: '.sha1($message)."\n";
        echo 'crc32: '.crc32($message)."\n";
        echo 'sha256: '.hash('sha256', $message)."\n";
        var_dump($message);
        exit;

        return new JsonResponse($bitcoin->getLastBlock());
    }
}
