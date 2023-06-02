use dep::std;

fn check_for_hit(mines: [Field; 5], dig: u8) -> bool {
    let mut hits = 0;
    for i in 0..5 {
        if dig == mines[i] as u8 {
            hits = hits + 1;
        }
    };
    hits as u8 > 0
}



fn main(hash: pub Field, hit: pub u1, mines: [Field; 5], dig: pub u8) {

   constrain dig < 25;

   // Ensure computed hash is equal to provided hash
   let computed_hash = std::hash::pedersen(mines);
   constrain hash == computed_hash[0];

   let hits = check_for_hit(mines, dig);
   constrain hits as u1 == hit;
}
