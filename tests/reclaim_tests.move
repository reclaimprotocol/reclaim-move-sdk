#[test_only]
module reclaim::reclaim_tests {
  use reclaim::reclaim;
  use sui::test_scenario;

#[test]
  fun test_reclaim() {
    let owner = @0xC0FFEE;
    let user1 = @0xA1;
    let epoch_duration_s = 1_000_000_u32;

    let mut scenario_val = test_scenario::begin(user1);
    let scenario = &mut scenario_val;

    test_scenario::next_tx(scenario, owner);
    {
      reclaim::create_reclaim_manager(epoch_duration_s,
                                      test_scenario::ctx(scenario));
    };

    test_scenario::next_tx(scenario, owner);
    {
      let mut witnesses = vector<reclaim::Witness>[];
      let witness = reclaim::create_witness(
          x"244897572368eadf65bfbc5aec98d8e5443a9072",
          b"http".to_string());
      witnesses.push_back(witness);

      let requisite_witnesses_for_claim_create = 1_u128;

      let mut manager =
          test_scenario::take_shared<reclaim::ReclaimManager>(scenario);

      reclaim::add_new_epoch(&mut manager, witnesses,
                             requisite_witnesses_for_claim_create,
                             test_scenario::ctx(scenario));

      test_scenario::return_shared(manager);
    };


   test_scenario::next_tx(scenario, user1);
    {
     let ctx = test_scenario::ctx(scenario);

      let claim_info = reclaim::create_claim_info(
         b"http".to_string(),
         b"{\"body\":\"\",\"geoLocation\":\"in\",\"method\":\"GET\",\"responseMatches\":[{\"type\":\"regex\",\"value\":\"_steamid\\\">Steam ID: (?<CLAIM_DATA>.*)</div>\"}],\"responseRedactions\":[{\"jsonPath\":\"\",\"regex\":\"_steamid\\\">Steam ID: (?<CLAIM_DATA>.*)</div>\",\"xPath\":\"id(\\\"responsive_page_template_content\\\")/div[@class=\\\"page_header_ctn\\\"]/div[@class=\\\"page_content\\\"]/div[@class=\\\"youraccount_steamid\\\"]\"}],\"url\":\"https://store.steampowered.com/account/\"}".to_string(),
         b"{\"contextAddress\":\"user's address\",\"contextMessage\":\"for acmecorp.com on 1st january\",\"extractedParameters\":{\"CLAIM_DATA\":\"76561199601812329\"},\"providerHash\":\"0xffd5f761e0fb207368d9ebf9689f077352ab5d20ae0a2c23584c2cd90fc1b1bf\"}".to_string()
      );

      let complete_claim_data = reclaim::create_claim_data(
        b"0xd1dcfc5338cb588396e44e6449e8c750bd4d76332c7e9440c92383382fced0fd".to_string(),
        b"0x13239fc6bf3847dfedaf067968141ec0363ca42f".to_string(),
        b"1".to_string(),
        b"1712174155".to_string(),
      );

      let mut signatures = vector<vector<u8>>[];
      let signature = x"2888485f650f8ed02d18e32dd9a1512ca05feb83fc2cbf2df72fd8aa4246c5ee541fa53875c70eb64d3de9143446229a250c7a762202b7cc289ed31b74b31c811c";
      signatures.push_back(signature);
      
      let signed_claim = reclaim::create_signed_claim(
        complete_claim_data,
        signatures
      );

      reclaim::create_proof(claim_info, signed_claim, ctx);
    };

  test_scenario::next_tx(scenario, user1);
    {
      let manager = test_scenario::take_shared<reclaim::ReclaimManager>(scenario);
      let proof = test_scenario::take_shared<reclaim::Proof>(scenario);

      // std::debug::print(&proof);
      
      let signers = reclaim::verify_proof(&manager, &proof);
      assert!(signers == vector[x"244897572368eadf65bfbc5aec98d8e5443a9072"], 0);

      test_scenario::return_shared(manager);
      test_scenario::return_shared(proof);
    };
    
    // reclaim::destruct_manager(manager);
    // let reclaim::ReclaimManager {id, owner, epoch_duration_s, current_epoch,
    // epochs, merkelized_user_params, dapp_id_to_external_nullifier} = manager;
    test_scenario::end(scenario_val);
  }
}