<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;

class HttpClientService
{
    private HttpClientInterface $client;

    public function __construct(HttpClientInterface $client)
    {
        $this->client = $client;
    }

    public function makePost(string $url, array $params): string
    {
        $response = $this->client->request('POST', $url, [
            'json' => $params,
        ]);

        return $response->getContent();
    }

    public function broadcast(array $networkNodes, string $path, array $params): array
    {
        $result = [];
        foreach ($networkNodes as $networkNodeUrl) {
            $url = $networkNodeUrl.$path;
            $result[] = $this->makePost($url, $params);
        }

        return $result;
    }
}
