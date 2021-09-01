<?php

namespace App\Service;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Contracts\HttpClient\HttpClientInterface;

class HttpClientService
{
    private HttpClientInterface $client;

    public function __construct(HttpClientInterface $client)
    {
        $this->client = $client;
    }

    public function request(string $url, array $params, $method = Request::METHOD_POST): string
    {
        $response = $this->client->request($method, $url, [
            'json' => $params,
        ]);

        return $response->getContent();
    }

    public function broadcast(array $networkNodes, string $path, array $params, $method = Request::METHOD_POST, callable $callback = null): void
    {
        foreach ($networkNodes as $networkNodeUrl) {
            $url = $networkNodeUrl.$path;
            $response = $this->request($url, $params, $method);
            if ($callback) {
                $callback($response);
            }
        }
    }
}
