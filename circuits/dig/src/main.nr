use dep::std;

fn check_for_hit(mines: [u8; 5], dig: u8) -> bool {
    let mut hits = 0;
    for i in 0..5 {
        if dig == mines[i] as u8 {
            hits = hits + 1;
        }
    };
    hits as u8 > 0
}



fn main(hash: pub [u8; 32], hit: pub u1, mines: [u8; 5], dig: pub u8) {

   assert(dig < 25);

   // Ensure computed hash is equal to provided hash
   let computed_hash = std::hash::sha256(mines);
   assert(hash == computed_hash);

   let hits = check_for_hit(mines, dig);
   assert(hits as u1 == hit);
}
