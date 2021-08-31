<?php

namespace App\Controller;

use App\Classes\Blockchain;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;

class ApiController extends AbstractController {
    public function test()
    {
        var_dump($_SERVER);
        die;
        $bitcoin = new Blockchain();

        return new JsonResponse($bitcoin);
    }
}
