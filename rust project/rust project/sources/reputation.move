module 0x1::reputation {
    use std::signer;
    use std::event;
    use std::error;

    // Errors
    const E_USER_REPUTATION_NOT_FOUND: u64 = 1;

    // Struct to store user reputation
    struct UserReputation has key {
        reputation_score: u64,
        event_handle: event::EventHandle<ReputationUpdatedEvent>,
    }

    // Event emitted when reputation is updated
    struct ReputationUpdatedEvent has copy, drop, store {
        user: address,
        new_score: u64,
    }

    // Initialize a new user's reputation
    public fun initialize_user(user: &signer) {
        let user_address = signer::address_of(user);
        let event_handle = event::new_event_handle<ReputationUpdatedEvent>(user_address);

        let user_rep = UserReputation {
            reputation_score: 0,
            event_handle,
        };

        move_to(user, user_rep);
    }

    // Update a user's reputation score
    public fun update_reputation(user: address, change: u64, increase: bool) acquires UserReputation {
        // Check if the user has a reputation resource
        assert!(exists<UserReputation>(user), error::not_found(E_USER_REPUTATION_NOT_FOUND));

        let user_rep = borrow_global_mut<UserReputation>(user);
        let current_score = user_rep.reputation_score;

        let new_score = if (increase) {
            // Handle overflow manually
            if (current_score + change < current_score) {
                18446744073709551615 // u64::MAX
            } else {
                current_score + change
            }
        } else {
            // Prevent underflow
            if (current_score < change) {
                0
            } else {
                current_score - change
            }
        };

        user_rep.reputation_score = new_score;

        // Emit event
        event::emit(&mut user_rep.event_handle, ReputationUpdatedEvent {
            user,
            new_score: user_rep.reputation_score,
        });
    }

    // Get a user's reputation score
    public fun get_reputation(user: address): u64 acquires UserReputation {
        assert!(exists<UserReputation>(user), error::not_found(E_USER_REPUTATION_NOT_FOUND));
        let user_rep = borrow_global<UserReputation>(user);
        user_rep.reputation_score
    }

    // Helper function to check if a user has a reputation resource
    public fun has_reputation(user: address): bool {
        exists<UserReputation>(user)
    }
}