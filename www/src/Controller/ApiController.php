<?php

namespace App\Controller;

use App\Classes\Blockchain;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class ApiController extends AbstractController {
    public function test()
    {
        $bitcoin = new Blockchain();

        var_dump($bitcoin);
        die;
    }
}
