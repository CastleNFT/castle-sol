// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./StringUtils.sol";

/** @title Puzzle Contract */
contract PuzzleContract is ERC1155, Ownable {
  uint16[4] private puzzlesPerTier;

  bool public mintingEnabled;
  bool public mintingDone;

  constructor(uint16[4] memory _puzzlesPerTier)
    ERC1155(
      "https://bafybeibigzpasy5bx2hnzeqzoanscaaspjz6kgswpmzs6s2bcpvaa4y2mq.ipfs.dweb.link/{id}.json"
    )
  {
    puzzlesPerTier = _puzzlesPerTier;
  }

  /** @dev Enables minting.
   * @param enabled boolean indicating the minting state to be set
   * @return _mintingEnabled whether minting is enabled now
   */
  function setMintingEnabled(bool enabled)
    public
    onlyOwner
    returns (bool _mintingEnabled)
  {
    require(!mintingDone, "Minting has already been done.");
    console.log("Setting mintingEnabled to %s", enabled);
    return mintingEnabled = enabled;
  }

  /** @dev Mints all puzzles to the sender and disables minting.
   */
  function mintAllPuzzles() public onlyOwner {
    require(mintingEnabled, "Minting is disabled.");
    console.log("Minting puzzles to %s", msg.sender);
    for (uint256 i = 1; i <= puzzlesPerTier.length; i++) {
      _mint(msg.sender, i, puzzlesPerTier[i - 1], "");
    }
    (mintingEnabled, mintingDone) = (false, true);
  }
}
