// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // Per l'oracolo Chainlink

contract DynamicNFT is ERC721 {
    string public baseTokenURI;
    uint256 public lastUpdateTime;
    AggregatorV3Interface internal priceFeed;  // Integrazione con oracolo Chainlink

    constructor() ERC721("DynamicNFT", "DNFT") {
        baseTokenURI = "https://api.nft.com/metadata/initial"; // URI iniziale dei metadati
        lastUpdateTime = block.timestamp;  // Memorizza il tempo iniziale
        priceFeed = AggregatorV3Interface(0x...); // Indirizzo dell'oracolo (ad esempio, ETH/USD)
    }

    // Funzione che aggiorna i metadati ogni 2 minuti
    function updateMetadata() public {
        require(block.timestamp >= lastUpdateTime + 2 minutes, "Metadata can only be updated every 2 minutes");
        
        // Aggiorna i metadati dell'NFT (ad esempio, cambia l'immagine o il colore)
        baseTokenURI = "https://api.nft.com/metadata/nextStage"; // Cambia l'URI dei metadati
        lastUpdateTime = block.timestamp; // Aggiorna il timestamp
    }

    // Funzione che rileva il trasferimento dell'NFT e cambia l'aspetto
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
        
        // Modifica i metadati dell'NFT ogni volta che viene trasferito
        baseTokenURI = "https://api.nft.com/metadata/onTransfer";
    }

    // Funzione che usa l'oracolo per cambiare i metadati in base al prezzo dell'ETH
    function updateBasedOnPrice() public {
        (,int price,,,) = priceFeed.latestRoundData();
        if (price > 3000 * 10 ** 8) {  // Esempio: cambia i metadati se ETH è sopra i 3000 USD
            baseTokenURI = "https://api.nft.com/metadata/newStage";
        }
    }

    // Funzione che restituisce l'URI del token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return baseTokenURI;
    }
}
