<?php

namespace App\Classes;

class Blockchain
{
    public array $chain = [];
    public array $pendingTransactions = [];

    public function createNewBlock(int $nonce, string $previousBlockHash, string $hash): array
    {
        $newBlock = [
            'index' => count($this->chain) + 1,
            'timestamp' => time(),
            'transactions' => $this->pendingTransactions,
            'nonce' => $nonce,
            'hash' => $hash,
            'previousBlockHash' => $previousBlockHash,
        ];

        $this->pendingTransactions = [];
        $this->chain[] = $newBlock;

        return $newBlock;
    }

    public function getLastBlock(): array
    {
        $index = count($this->chain) - 1;

        return $this->chain[$index];
    }
}
