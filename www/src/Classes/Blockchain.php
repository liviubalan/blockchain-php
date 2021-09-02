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

    public function chainIsValid(array $blockchain): bool
    {
        // Skip genesis block
        $blockchainCount = count($blockchain);
        for ($i = 1; $i < $blockchainCount; $i++) {
            $currentBlock = $blockchain[$i];
            $prevBlock = $blockchain[$i - 1];
            $blockHash = $this->hashBlock($prevBlock['hash'], [
                'transactions' => $currentBlock['transactions'],
                'index' => $currentBlock['index'],
            ], $currentBlock['nonce']);

            if (substr($blockHash, 0, 4) !== '0000') {
                return false;
            }

            if ($currentBlock['previousBlockHash'] !== $prevBlock['hash']) {
                return false;
            }
        }

        // Genesis block
        $genesisBlock = $blockchain[0];
        $correctIndex = $genesisBlock['index'] === 1;
        $correctTransactions = $genesisBlock['transactions'] === [];
        $correctNonce = $genesisBlock['nonce'] === 0;
        $correctHash = $genesisBlock['hash'] === '0';
        $correctPreviousBlockHash = $genesisBlock['previousBlockHash'] === '0';

        return $correctIndex && $correctTransactions && $correctNonce && $correctHash && $correctPreviousBlockHash;
    }

    public function getBlock(string $blockHash): ?array
    {
        foreach ($this->chain as $block) {
            if ($block['hash'] === $blockHash) {
                return $block;
            }
        };

        return null;
    }

    public function getTransaction(string $transactionId): ?array
    {
        foreach ($this->chain as $block) {
            foreach ($block['transactions'] as $transaction) {
                if ($transaction['transactionId'] === $transactionId) {
                    return [
                        'transaction' => $transaction,
                        'block' => $block,
                    ];
                }
            }
        };

        return null;
    }

    public function getAddress(string $address): ?array
    {
        $addressTransactions = [];
        foreach ($this->chain as $block) {
            foreach ($block['transactions'] as $transaction) {
                if ($transaction['sender'] === $address || $transaction['recipient'] === $address) {
                    $addressTransactions[] = $transaction;
                }
            }
        };

        $balance = 0;
        foreach ($addressTransactions as $transaction) {
            if ($transaction['recipient'] === $address) {
                $balance += $transaction['amount'];
            } else {
                if ($transaction['sender'] === $address) {
                    $balance -= $transaction['amount'];
                }
            }
        }

        return [
            'addressTransactions' => $addressTransactions,
            'addressBalance' => $balance,
        ];
    }

    public static function arrayToObject(array $array): self
    {
        $object = new self('');
        foreach ($array as $key => $value) {
            $object->$key = $value;
        }

        return $object;
    }
}
