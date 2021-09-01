<?php

namespace App\Service;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;

class ValidatorService
{
    public function checkMandatoryFields(Request $request, array $fields): void
    {
        $content = trim($request->getContent());
        if (!$content) {
            throw new BadRequestHttpException('Empty request');
        }

        $content = json_decode($content, true);
        foreach ($fields as $field) {
            if (!array_key_exists($field, $content)) {
                throw new BadRequestHttpException(
                    sprintf('The following field is mandatory: %s.', $field)
                );
            }
        }
    }
}
