use dep::std;


fn check_for_collision(mines: [Field; 5]) {
    let mut collisions = 0;
    for i in 0..5 {

        for j in 0..5 {

            if(mines[i] == mines[j]) {
                collisions = collisions + 1;
            }
        };
    };
    constrain collisions == 0;
}


fn main(hash: pub Field, mines: [Field; 5]) {
    // Check ship ranges
    for i in 0..5 {
     constrain mines[i] as u16 < 25;
    };
    // Ensure ships have valid placement and do not share coordinates with each other
    check_for_collision(mines);
    // Check integrity of ship hash
    let computed_hash = std::hash::pedersen(mines);
    constrain hash == computed_hash[0];
}
