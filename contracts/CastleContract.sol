// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./PieceContract.sol";
import "./PuzzleContract.sol";
import "./ArrayUtils.sol";

/** @title Castle Contract */
contract CastleContract is ERC1155Holder, Ownable {
  PieceContract public pieceContract;
  PuzzleContract public puzzleContract;

  uint16[4] public puzzlesPerTier = [1, 2, 3, 4];

  uint8 public rowCount = 5;
  uint8 public columnCount = 5;
  uint8 public tierCount = uint8(puzzlesPerTier.length);
  uint8 private goldTier = 1;
  uint8 private silverTier = 2;
  uint8 private ironTier = 3;
  uint8 private bronceTier = 4;

  bool private subContractsDeployed;

  /** @dev Deploys an instance of both PieceContract and PuzzleContract.
   */
  function deploySubContracts() external onlyOwner {
    require(!subContractsDeployed, "ALREADY_DEPLOYED");
    pieceContract = new PieceContract(puzzlesPerTier, rowCount, columnCount);
    puzzleContract = new PuzzleContract(puzzlesPerTier);
    subContractsDeployed = true;
  }

  /** @dev Enables minting on the children contracts.
   * @return success if both contracts are now enabled to mint
   */
  function prepareMinting() external onlyOwner returns (bool success) {
    return
      pieceContract.setMintingEnabled(true) &&
      puzzleContract.setMintingEnabled(true);
  }

  /** @dev Mints all pieces to an address and all puzzles to itself.
   * @param mintPiecesTo address to send the minted pieces to
   */
  function runMinting(address mintPiecesTo) external onlyOwner {
    pieceContract.mintAllPieces(mintPiecesTo);
    puzzleContract.mintAllPuzzles();
  }

  /** @dev Checks if a user can lock their pieces and retrieve a puzzle.
   * @param tier the tier of which pieces should be checked for
   * @return success whether the user is able to lock pieces
   */
  function canLockPiecesForTier(uint8 tier) public view returns (bool success) {
    bool flag;
    uint256[] memory ids = pieceContract.getTokenIdsOfTier(tier);
    for (uint256 i = 0; i < ids.length; i++) {
      flag = pieceContract.balanceOf(msg.sender, ids[i]) == 0;
    }
    return !flag;
  }

  /** @dev Locks a users pieces and returns a puzzle to the user.
   * @param tier the tier of the pieces to be locked
   * @return success if the transfer has been finished successfully
   */
  function lockPieces(uint8 tier) external returns (bool success) {
    require(canLockPiecesForTier(tier), "INCOMPLETE_PUZZLE");
    require(
      pieceContract.isApprovedForAll(msg.sender, address(this)),
      "NOT_APPROVED"
    );
    pieceContract.safeBatchTransferFrom(
      msg.sender,
      address(this),
      pieceContract.getTokenIdsOfTier(tier),
      ArrayUtils.getFilledArray(rowCount * columnCount, 1),
      ""
    );
    puzzleContract.safeTransferFrom(address(this), msg.sender, tier, 1, "");
    return true;
  }

  /** @dev Locks a users puzzle and returns its pieces to the user.
   * @param tier the tier of the puzzle to be locked
   * @return success if the transfer has been finished successfully
   */
  function retrievePieces(uint8 tier) external returns (bool success) {
    require(puzzleContract.balanceOf(msg.sender, tier) > 0, "NO_PUZZLE");
    require(
      puzzleContract.isApprovedForAll(msg.sender, address(this)),
      "NOT_APPROVED"
    );
    puzzleContract.safeTransferFrom(msg.sender, address(this), tier, 1, "");
    pieceContract.safeBatchTransferFrom(
      address(this),
      msg.sender,
      pieceContract.getTokenIdsOfTier(tier),
      ArrayUtils.getFilledArray(rowCount * columnCount, 1),
      ""
    );
    return true;
  }
}
