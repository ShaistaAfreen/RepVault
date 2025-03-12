module tests::reputation_test {
    use std::debug;
    use std::signer;
    use reputation;

    #[test]
    public fun test_reputation_flow(account: &signer) {
        let user_address = signer::address_of(account);

        // Initialize reputation
        reputation::initialize_user(account);
        assert!(reputation::has_reputation(user_address), 100);

        // Initial score should be 0
        let score = reputation::get_reputation(user_address);
        debug::print(&score); // Print score
        assert!(score == 0, 101);

        // Increase reputation by 10
        reputation::update_reputation(user_address, 10, true);
        let score_after_increase = reputation::get_reputation(user_address);
        debug::print(&score_after_increase); // Print score
        assert!(score_after_increase == 10, 102);

        // Decrease reputation by 5
        reputation::update_reputation(user_address, 5, false);
        let score_after_decrease = reputation::get_reputation(user_address);
        debug::print(&score_after_decrease); // Print score
        assert!(score_after_decrease == 5, 103);

        // Try to underflow (reputation can't be negative)
        reputation::update_reputation(user_address, 10, false);
        let score_after_underflow = reputation::get_reputation(user_address);
        debug::print(&score_after_underflow); // Print score
        assert!(score_after_underflow == 0, 104);
    }
}