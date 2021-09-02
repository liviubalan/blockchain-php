<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;

class WebController extends AbstractController
{
    public function blockExplorer(): Response
    {
        return $this->render('blockExplorer.html.twig');
    }
}
