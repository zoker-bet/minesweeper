use dep::std;


fn check_for_collision(mines: [u8; 5]) {
    let mut collisions = 0;
    for i in 0..5 {

        for j in 0..5 {

            if(mines[i] == mines[j]) {
                if (i != j) {
                    collisions = collisions + 1;
                }
            }
        };
    };
    assert(collisions == 0);
}


fn main(hash: pub [u8; 32], mines: [u8; 5]) {
    // Check ship ranges
    for i in 0..5 {
     assert(mines[i] as u16 < 25);
    };
    // Ensure ships have valid placement and do not share coordinates with each other
    check_for_collision(mines);
    // Check integrity of ship hash
    let computed_hash = std::hash::sha256(mines);
    assert(hash == computed_hash);
}
