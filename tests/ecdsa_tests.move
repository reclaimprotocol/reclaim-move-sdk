
#[test_only]
module reclaim::ecdsa_tests {
    use reclaim::ecdsa::ecrecover_to_eth_address;
    use sui::hash::keccak256;
    use std::string::as_bytes;
    #[test]
    fun test_recover() {
        
        let endl = b"\n".to_string();

        let provider = b"http".to_string();
        let parameters = b"{\"body\":\"\",\"geoLocation\":\"in\",\"method\":\"GET\",\"responseMatches\":[{\"type\":\"regex\",\"value\":\"_steamid\\\">Steam ID: (?<CLAIM_DATA>.*)</div>\"}],\"responseRedactions\":[{\"jsonPath\":\"\",\"regex\":\"_steamid\\\">Steam ID: (?<CLAIM_DATA>.*)</div>\",\"xPath\":\"id(\\\"responsive_page_template_content\\\")/div[@class=\\\"page_header_ctn\\\"]/div[@class=\\\"page_content\\\"]/div[@class=\\\"youraccount_steamid\\\"]\"}],\"url\":\"https://store.steampowered.com/account/\"}".to_string();
        let context = b"{\"contextAddress\":\"user's address\",\"contextMessage\":\"for acmecorp.com on 1st january\",\"extractedParameters\":{\"CLAIM_DATA\":\"76561199601812329\"},\"providerHash\":\"0xffd5f761e0fb207368d9ebf9689f077352ab5d20ae0a2c23584c2cd90fc1b1bf\"}".to_string();
        let mut claim_info_data = b"".to_string();
        claim_info_data.append(provider);
        claim_info_data.append(endl);
        claim_info_data.append(parameters);
        claim_info_data.append(endl);
        claim_info_data.append(context);

        let hash = keccak256(as_bytes(&claim_info_data));
        assert!(hash == x"d1dcfc5338cb588396e44e6449e8c750bd4d76332c7e9440c92383382fced0fd", 0);

        let mut identifier = b"0xd1dcfc5338cb588396e44e6449e8c750bd4d76332c7e9440c92383382fced0fd".to_string();

        let mut owner = b"0x13239fc6bf3847dfedaf067968141ec0363ca42f".to_string();
        let mut timestamp = b"1712174155".to_string();
        let epoch = b"1".to_string();

        
        identifier.append(endl);
        owner.append(endl);
        timestamp.append(endl);


        let mut message = b"".to_string();
        message.append(identifier);
        message.append(owner);
        message.append(timestamp);
        message.append(epoch);
    
        let mut eth_msg = b"\x19Ethereum Signed Message:\n".to_string();

        eth_msg.append(b"122".to_string());
        eth_msg.append(message);

        // let hasher = keccak256(bytes(&eth_msg));

        let msg = as_bytes(&eth_msg);
        
        // std::debug::print(&hasher);

        let signature = x"2888485f650f8ed02d18e32dd9a1512ca05feb83fc2cbf2df72fd8aa4246c5ee541fa53875c70eb64d3de9143446229a250c7a762202b7cc289ed31b74b31c811c";
        
        let addr = ecrecover_to_eth_address(signature, *msg);

        /*
        serialized claim: "0xd1dcfc5338cb588396e44e6449e8c750bd4d76332c7e9440c92383382fced0fd\n0x13239fc6bf3847dfedaf067968141ec0363ca42f\n1712174155\n1"
        serialized claim length: 7a (122)
        
        eth message: "19457468657265756d205369676e6564204d6573736167653a0a3132323078643164636663353333386362353838333936653434653634343965386337353062643464373633333263376539343430633932333833333832666365643066640a3078313332333966633662663338343764666564616630363739363831343165633033363363613432660a313731323137343135350a31"
        eth message hash: "c32e57b71247c1aab4b93bb0a2bb373186acc2d5c9bd8dfcd046e1d0553fd421"

        */

        assert!(addr == x"244897572368eadf65bfbc5aec98d8e5443a9072", 0);
    }  
}

