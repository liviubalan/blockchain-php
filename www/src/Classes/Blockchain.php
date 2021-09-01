<?php

namespace App\Classes;

class Blockchain
{
    public array $chain = [];
    public array $pendingTransactions = [];
    public string $currentNodeUrl = '';
    public array $networkNodes = [];

    public function __construct(string $currentNodeUrl)
    {
        $this->currentNodeUrl = $currentNodeUrl;
        $this->createNewBlock(0, '0', '0'); // Genesis block
    }

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

    public function createNewTransaction(float $amount, string $sender, string $recipient): array
    {
        return [
            'amount' => $amount,
            'sender' => $sender,
            'recipient' => $recipient,
            'transactionId' => uniqid(),
        ];
    }

    public function addTransactionToPendingTransactions(array $newTransaction): int
    {
        $this->pendingTransactions[] = $newTransaction;

        return $this->getLastBlock()['index'] + 1;
    }

    public function hashBlock(string $previousBlockHash, array $currentBlockData, int $nonce): string
    {
        $dataAsString = $previousBlockHash.(string) $nonce.json_encode($currentBlockData);

        return hash('sha256', $dataAsString);
    }

    public function proofOfWork(string $previousBlockHash, array $currentBlockData): int
    {
        $nonce = 0;
        $hash = $this->hashBlock($previousBlockHash, $currentBlockData, $nonce);
        while (substr($hash, 0, 4) !== '0000') {
            $nonce++;
            $hash = $this->hashBlock($previousBlockHash, $currentBlockData, $nonce);
        }

        return $nonce;
    }
}
