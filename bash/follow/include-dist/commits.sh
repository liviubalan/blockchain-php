#!/bin/bash

BTC_COMMIT_HASH=(
    '835748c3c3abac1b1f87dcbd8799406c08ed7408' # Step 0 - Genesys, may not be used as step
    '0a9161a36218d194c23b3818ece6dce1bcf9dd7a' # Step 1 - Start from here
    'd93e6116116288fd26b2a7ff9c98b340a01fe53b' # Step 2
    'de59c9641acd99a97e02b0084c0d3600cb5f167f'
    '3e40ce909c7a6b33f1615aa1f690006304a5a235'
    '62b6ac6b71b3bd16b5803eaa54bb59d9a34096cc'
    'd0bf5a43f8e3d8d21c42f0b3e65d42e59c9867e4'
    '7814fdfa5e98fa1c6d27205879a65d420337b5af'
    'f76c069abe323a7e2852d06c1dd11d16fbfcdb38'
    '36b147787b7541f7b82d6fa6a0ef3342fd276321'
    'f80478cc34263ef00159a7c28ae4fb1be72f7c53'
    '9e2885340b8513b832272680850fb113dee8ecc3'
    'fc247b2a6bce72380a93f3ffa56ccba0095fa25f'
    'c5f57e7a535adf8c7efe77daaf47d32959965de2'
    'd59048599cfbd9290be80b556b4bd9fb93de6d25'
    '8bb0d950582ea8600118f4cafbcd485ee3db438f'
    'f12d57f1f8c6d1ce98d18a0500890dfe5a80ebc2'
    '02da48d6627e3b98e4bd618d663dd7bca83282af'
    '7834d8d8a8127c88712635ea98ce531b493a59be'
    '880fe37eba78de84b64bbe90037f2e5562a5e434'
    '78581804683a3d48dab8e75fa38c5173f7698476'
    '76db3c5ced224c7e5e2bded7d9c3c7b65de20926'
    '1c19f477f4fd7777028f6ce422cc81d1fee887cf'
    'f157d43b53419c823b4d23d8d32c2df8d3c343a6'
    '5708812639014f217367c0a052c299477b9cb70e' # Test
    'e2f4de1763e7791f3aca600c34acf4ddd2789cf4'
    'd7eef41dc6fd084d661425e876ff63901186fc69'
    '5f0c6755fe2076a27bc09f0e970cf91acdf925b8'
    'bdb0d3ab6c77efd239139d55805ddb3586904b97'
    '468f38b6b9814a9d04c597176cab0f7edcb64a00'
    '9c745e96ad909aab9eae772cbf6e00c693eea412'
    '0850aa7f0b7a1baccd229d4d10ec7faa07f80cf8'
    '8650d6481bcfe0fc7fcb20c9b759541b37337f5a'
    '57c0282ff8bed0ba554b6b28834d0433da9385ad'
    '58a2dce0961022000c91c91434973e56bb5d45e8'
    'fc6ee19a99c6fb155a43a8772986e7804036f8c5'
    '7b19397a63a0317fd99cbeff89dfdbbe1b58f030'
    'bd132d3be10bcebef05f9e2ec55e6a43e18f4152'
    '3caa52b2194ef3a3ad18a98d8fc4619e187fe1bd'
    'fdaed86169facbf69db8d3b231bb1e1e31b7a090'
    '071e9f6c21ca372d38eddec107e8aed4a7a55cb1'
    'd969bfacd38c5b891fbdc8e9c9f262e95d0f864b'
    '49f1a9a4e417623d8f6bc414431b6a8c26a20c36'
    '64303300b9f181abc0f49499e44a43cf37c9bc6c'
    '1a0f04ec3bff127ed3d0fdf84aa4d7e62f592095'
    '4259659719aa5595894468528c5dfafccf931538'
    '3fd004ad762a05ff44eb6294134aed6a1f392664'
    '41f9a9354b2e8d4920cad3e80497e32570995e36'
    'b35fba34cb90b96975b911812cf6040c1b1b2f4d'
    'c0c6789e80f439131c9389732445e55ce5468fe4'
    'a62a757d9c86f8ad8f9874a22d52e14ea985ef28'
    '05fc9df0763efa53d60312348d7af1590f6506dd'
    '227993db5e83c6f8acc0881f51125907d23d5cc4'
    'a0bafd247bd5606dcfe27a0baf153338433bef3a'
    '237fa22b33cc85bb824df71a55937e25455bdf1e'
    '5431795ad4e9e0bd001def2f795b01da0f751de1'
    '56fd6f4e125318e4ea1eee14a563900b6847d363'
    'a8e5e3d911b88cc210837d59be4909ee7b52e186'
    'c0a07a67873704713bc335907efcebcf38f84f9a'
    '72bf8058764c6eb9bc9b873a8b3b4de991820012'
    'e2fa1979387e4ddd82fa04af2c1f7252c837462d'
    '8cb0aa020f72f3f3070a0c4388a39823ad3eea86'
    '620aacd375767adb0cbe6bc3080014117350cdae'
    'f2d0e81ef6b2fe8d6672a9483bfd54107c5bcf67'
    '78c7cd76349fc5b51facfe59130f21d9676b01c6'
    'a5c4a39e9e1371446b3839b40e75e3ebaa798ae9'
    '7baf9f9622796f890588f53630faa20653b9a1bd'
    'ae39141c496dd284c58a38eb369ffc26788338f5'
    '5d3c29ec3c427200b68607faf816a5ac4edec3e8'
    '7d8081fbd4fefaae4630d7ca3519613bdce9c9e3'
    '44ca4c78d2cfa0c521c754c1c405089faa49c8a2'
)

BTC_COMMIT_DESCRIPTION=(
    'Add tool "follow.sh"'
    'Add "Vagrantfile"'
    'Use Vagrant box "Centos 7"'
    'Create private network'
    'Provider-specific configuration'
    'Config hostname'
    'Provisioning with "bootstrap.sh"'
    'Install Git'
    'Install Nginx'
    'Install PHP'
    'Move "provision-shell/bootstrap.sh" to "bash/provision/bootstrap.sh"'
    'Create Nginx virtual host'
    'Use "www/" for virtual host'
    'Use group "www-data"'
    'Add composer'
    'Add Symfony 4.4'
    'Use Symfony Nginx virtual host'
    'Provision changes'
    'Use "sites-available/" for Nginx virtual host'
    'Use "btc_strf_replace_once" instead of "sed"'
    'Changes to "composer.json"'
    'Create "Blockchain" class + route "/test"'
    'Return JSON response on route "/test"'
    'Create method "Blockchain::createNewBlock"'
    'Create method "Blockchain::getLastBlock"' # Test
    'Test PHP hashing functions'
    'Create method "Blockchain::createNewTransaction"'
    'Blockchain usage: method "createNewBlock"'
    'Blockchain usage: "createNewTransaction" + "createNewBlock"'
    'Blockchain usage: "createNewTransaction" + "createNewBlock"'
    'Blockchain usage: "createNewTransaction" + "createNewBlock"'
    'Create method "Blockchain::hashBlock"'
    'Create method "Blockchain::proofOfWork"'
    'Create Genesis block'
    'Vagrant multiple machines: Add second PHP node'
    'Check PHP $_SERVER info'
    'Config Nginx virtual host based on machine hostname'
    'Create route "/blockchain"'
    'Create route "/transaction"'
    'Save data between requests'
    'Create endpoint "/mine"'
    'Change mining node address'
    'Change "/var" location'
    'Fix hostname in CLI'
    'Add 5 nodes + change memory usage'
    'Build endpoint "/register-node"'
    'Build endpoint "/register-nodes-bulk"'
    'Add "ValidatorService"'
    'Build endpoint "/register-and-broadcast-node"'
    'Build endpoint "/transaction/broadcast"'
    'Create and use "HttpClientService::broadcast"'
    'Build endpoint "/receive-new-block"'
    'Refactor endpoint "/mine"'
    'Fix "bitcoin" cached property overwrite'
    'Fix JsonResponse'
    'Create and test "Blockchain::chainIsValid"'
    'Refactor method "Blockchain::chainIsValid"'
    'Refactor "HttpClientService::makePost" to "HttpClientService::request"'
    'Add "$method" param to "HttpClientService::broadcast"'
    'Build endpoint "/consensus"'
    'Add "README.md" + Postman collection + follow.sh commit'
    'Build endpoint "/block/{blockHash}"'
    'Build endpoint "/transaction/{transactionId}"'
    'Build endpoint "/address/{address}"'
    'Split "routes.yaml" to "api.yaml" and "web.yaml"'
    'Add "symfony/twig-bundle"'
    'Build endpoint "/block-explorer"'
    'Add bootstrap'
    'Behavior for "block-explorer"'
    'JS/CSS fine tunning'
    'Fix dir creation on "follow.sh"'
)
