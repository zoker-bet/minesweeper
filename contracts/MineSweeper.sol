//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
import "./IVerifier.sol";

contract MineSweeper {

    uint256 public constant HIT_MAX = 5;

    IBoardVerifier bv; // verifier for proving initial board rule compliance
    IDigVerifier dv;
    uint256 public gameIndex;
    mapping(uint256 => Game) public games; // map game nonce to game data

    /// STRUCTS ///

    struct Game {
        address host;
        address player;
        bytes32[] board; // sha256 hash of board
        uint8 nonce; // turn #
        mapping(uint8 => uint8) digPosition; // map turn number to dig coordinates
        mapping(uint8 => bool) digged; // Ensure digs are only made once
        uint8 digNonce; // track # of hits player has made
        GameStatus status; // game lifecycle tracker
        address winner; // game winner
        bool canEnd;
    }

    enum GameStatus {
        NotStarted,
        Started,
        Over
    }

    /// CONSTRUCTOR ///
    constructor(
        address _bv,
        address _sv
    ){
        bv = IBoardVerifier(_bv);
        dv = IDigVerifier(_sv);
    }

    function newGame(bytes memory _proof, bytes32[] calldata _publicInputs) external {
        require(bv.verify(_proof, _publicInputs), "Invalid Board Config!");
        games[gameIndex].host = msg.sender;
        games[gameIndex].board = _publicInputs;
        games[gameIndex].status = GameStatus.NotStarted;
        gameIndex++;
    }

    function join(uint256 _game) external {
        require(games[_game].status == GameStatus.NotStarted && _game <= gameIndex, "Game status invalid");
        games[_game].player = msg.sender;
        games[_game].status = GameStatus.Started;
    }

    function dig(uint256 _game, uint8 _position) external {
        Game storage game = games[_game];
        require(game.status == GameStatus.Started && _game <= gameIndex, "Game status invalid");
        require(game.player == msg.sender, "Only player can make tx");
        require(!game.digged[_position], "Already selected");
        game.digPosition[game.digNonce] = _position;
        game.digNonce++;
    }

}