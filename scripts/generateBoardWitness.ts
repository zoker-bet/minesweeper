import { stringify } from "@iarna/toml";
import { BarretenbergWasm } from '@noir-lang/barretenberg/dest/wasm';
import { writeFileSync } from 'fs';
import { Sha256 } from '@noir-lang/barretenberg/dest/crypto/sha256';
import { SinglePedersen } from '@noir-lang/barretenberg/dest/crypto/pedersen';
import { numToHex } from "../utils";

/**
 * Generate the witness for the Noir board proof
 */
(async () => {
    const barretenberg = await BarretenbergWasm.new();
    const sha256 = new Sha256(barretenberg);
    const pedersen = new SinglePedersen(barretenberg);
    // Number array of length 15 for sip coordinates (all values must be below 9 with every third either
    // 0 or 1 to represent orientation
    const mines = [1, 2, 3, 4, 5];
    // Coordinate array must have values coverted to a 32 bytes hex string for Barretenberg Pedersen to match Noir's
    // implementation. Returns a buffer
    const mineBuffer = sha256.hash(Buffer.from(mines));
    // const raw = mines.map(mine => Buffer.from(numToHex(mine), 'hex'));
    // const raw = mines.map(mine => `0x${Buffer.from(numToHex(mine), 'hex').toString('hex')}`);
    // console.log(raw)
    // const mineBuffer = pedersen.compressInputs(raw);
    console.log(mineBuffer)
    const hash = mineBuffer.toJSON().data;
    console.log(hash);
    // Convert pedersen buffer to hex string and prefix with "0x" to create hash
    const hashed = `0x${mineBuffer.toString('hex')}`
    console.log(hashed);
    // Convert to TOML and write witness to prover.toml and public inputs to verified
    writeFileSync('circuits/board/Prover.toml', stringify({ hash, mines, hashed }));
    // console.log('Board witness written to /board/Prover.toml');
    writeFileSync('circuits/board/Verifier.toml', stringify({
        setpub: [],
        hash,
        hashed
    }));
    console.log('Board verifier written to /board/Verifier.toml');
})();