<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;

class HttpClientService
{
    /**
     * @var HttpClientInterface
     */
    private $client;

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
}
