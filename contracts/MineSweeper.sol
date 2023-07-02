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
        address nextTurn;
    }

    enum GameStatus {
        NotStarted,
        Started,
        Over
    }

    /// CONSTRUCTOR ///
    constructor(
        address _bv,
        address _dv
    ){
        bv = IBoardVerifier(_bv);
        dv = IDigVerifier(_dv);
    }

    function preparePublicInputs(
        bytes32[] memory _publicInputs,
        bytes32 publicInput,
        uint256 offset
    ) private pure returns (bytes32[] memory) {
        for (uint256 i = 0; i < 32; i++) {
            _publicInputs[i + offset] = (publicInput >> ((31 - i) * 8)) & bytes32(uint256(0xFF));
        } // TODO not cool, padding 31 bytes with 0s
        return _publicInputs;
    }

    function newGame(bytes memory _proof, bytes32 hashed) external {
        bytes32[] memory _publicInputs = new bytes32[](32);
        _publicInputs = preparePublicInputs(_publicInputs, hashed, 0);
        require(bv.verify(_proof, _publicInputs), "Invalid Board Config!");
        games[gameIndex].host = msg.sender;
        // games[gameIndex].board = _publicInputs;
        games[gameIndex].status = GameStatus.NotStarted;
        gameIndex++;
    }

    function join(uint256 _game) external {
        require(games[_game].status == GameStatus.NotStarted && _game <= gameIndex, "Game status invalid");
        games[_game].player = msg.sender;
        games[_game].status = GameStatus.Started;
        games[_game].nextTurn = msg.sender;
    }

    function dig(uint256 _game, uint8 _position) external {
        Game storage game = games[_game];
        require(msg.sender == game.nextTurn, "Dont have right to make tx");
        require(game.status == GameStatus.Started && _game <= gameIndex, "Game status invalid");
        require(game.player == msg.sender, "Only player can make tx");
        require(!game.digged[_position], "Already selected");
        game.digPosition[game.digNonce] = _position;
        game.digNonce++;
        game.nextTurn = game.host;
    }

    function revealDig(bytes memory _proof, uint256 _game, uint8 _hit, bytes32 _hashed) external {
        Game storage game = games[_game];
        require(msg.sender == game.nextTurn, "Dont have right to make tx");
        require(game.status == GameStatus.Started && _game <= gameIndex && game.digNonce > 0, "Game status invalid");
        require(_hit < 2, "Invalid hit");
        bytes32[] memory _publicInputs = new bytes32[](34);
        _publicInputs = preparePublicInputs(_publicInputs, _hashed, 0);
        _publicInputs[32] = bytes32(uint256(_hit));
        _publicInputs[33] = bytes32(uint256(game.digPosition[game.digNonce - 1]));
        require(bv.verify(_proof, _publicInputs), "Invalid proof");
        if (_hit == 1) {
            game.status = GameStatus.Over;
            game.winner = msg.sender;
        } else {
            if (game.digNonce == 21) { // 20 in a row
                game.status = GameStatus.Over;
                game.winner = game.player;
            }
        }
    }

    function leaveGame(uint256 _game) external {
        Game storage game = games[_game];
        require(game.status != GameStatus.Over, "Game over");
        if (game.player == msg.sender) {
            game.winner = game.host;
        } else if(game.host == msg.sender) {
            if (game.status == GameStatus.Started) {
                game.winner = game.player;
            }
        } else {
            revert("You are not in game");
        }
        game.status = GameStatus.Over;
    }

}