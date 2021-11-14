// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./StringUtils.sol";

/** @title Piece Contract */
contract PieceContract is ERC1155, Ownable {
  uint16[4] private puzzlesPerTier;
  uint8 private rowCount;
  uint8 private columnCount;

  bool public mintingEnabled;
  bool public mintingDone;

  constructor(
    uint16[4] memory _puzzlesPerTier,
    uint8 _rowCount,
    uint8 _columnCount
  )
    ERC1155(
      "https://bafybeianv56sdv2ajdopcdvi5f6hrt65rww6oryg3olrmec5bwb6zlsdpi.ipfs.dweb.link/{id}.json"
    )
  {
    puzzlesPerTier = _puzzlesPerTier;
    rowCount = _rowCount;
    columnCount = _columnCount;
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

  /** @dev Mints all pieces to a specified address and disables minting
   * @param mintTo address where pieces are minted to
   */
  function mintAllPieces(address mintTo) public onlyOwner {
    require(mintingEnabled, "Minting is disabled.");
    console.log("Minting pieces to %s", mintTo);
    for (uint8 tier = 1; tier <= puzzlesPerTier.length; tier++) {
      for (uint8 row = 1; row <= rowCount; row++) {
        for (uint8 col = 1; col <= columnCount; col++) {
          _mint(
            mintTo,
            calcTokenId(tier, row, col),
            puzzlesPerTier[tier - 1],
            ""
          );
        }
      }
    }
    (mintingEnabled, mintingDone) = (false, true);
  }

  /** @dev Calculates tokenId based on tier, row and column
   * @param tier one of the defined tiers
   * @param row the row in the puzzle
   * @param column the column in the puzzle
   * @return _tokenId the calculated tokenId
   */
  function calcTokenId(
    uint8 tier,
    uint8 row,
    uint8 column
  ) public view returns (uint256 _tokenId) {
    return
      1 +
      (uint256(tier - 1) * uint256(rowCount) * uint256(columnCount)) +
      (uint256(row - 1) * uint256(rowCount) + uint256(column - 1));
  }

  /** @dev Calculates tokenIds based on tier
   * @param tier one of the defined tiers
   * @return _tokenIds the array of tokenIds for the specified tier
   */
  function getTokenIdsOfTier(uint8 tier)
    public
    view
    returns (uint256[] memory _tokenIds)
  {
    require(tier <= puzzlesPerTier.length, "Tier exceeds max value.");
    require(tier >= 1, "Tier exceeds min value.");
    uint256[] memory ids = new uint256[](rowCount * columnCount);
    for (uint8 row = 1; row <= rowCount; row++) {
      for (uint8 col = 1; col <= columnCount; col++) {
        ids[
          uint256(row - 1) * uint256(rowCount) + uint256(col - 1)
        ] = calcTokenId(tier, row, col);
      }
    }
    return ids;
  }
}
