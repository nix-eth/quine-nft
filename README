## The article "[Quine: Algo vs. Output, the NFT that serves itself](https://nix.art/quine)" is the why. This repo is the how.

Everything about this study is open source. I applied the CC0 license to the NFT and the MIT license to all code. If you use any of it, it would be nice to hear how ([@nix_eth on X](https://x.com/nix_eth)).

I will not verify the source code for [my deployed instance on Etherscan](https://etherscan.io/address/0x765fa2a9801ddadf294130adc6ddf4fe15148bae#code) because the entire point is that the bytecode serves itself. I like that anyone can easily check that the runtime bytecode matches the NFT text.

The source can be deployed as is, there are no constructor arguments or dependencies. When deployed it [mints the only NFT (`id 0`)](https://opensea.io/assets/ethereum/0x765fa2a9801ddadf294130adc6ddf4fe15148bae/0) back to the deployer. At that point it behaves like any other NFT. There is no ability to mint additional NFTs. The contract also permanently returns the deployers address as `owner()` so most dapps properly show the "creator".

## When I set out to create this in Solidity, I had the following requirements:

- Keep the runtime bytecode as small as possible, I felt less looked better in the rendered NFT and made a more compelling example. Some of the source is ugly because I kept trialing what produced smaller runtime bytecode.
- Meet the minimum ERC-721 requirements while respecting the previous requirement. This is how I ended up with the unusual logic that only supports a single token minted on deploy. I also rigged safe transfers so they aren't really safe (doesn't check the receiver).
- Be completely self-contained. The only functions are to transfer the NFT. I also implemented `contractURI` so it serves its own collection data.
- Apply as little formatting as possible in the SVG output. Keeping with the concept I didn't want the output to feel materially different from the source.

I won't walk completely through the source code. The unique part relating to this study starts with `contractURI()`

## Challenges I faced:

Text support in SVGs is rough. There is also no support for wrapping. I had to break the bytecode up into lines, use `lengthAdjust` with a set width, place each row on the y axis, use monospaced fonts, and pad to make the last row even (see ` _contractToSvg()`). This seems to work well in different browsers/renderers.

Casting bytes to a hex string in Solidity is easy with addresses, but I couldn't find a library to do it with the contract bytecode. I am doing this manually in ` _contractToSvg()` but if I was going to use this concept in something bigger I would take the time to abstract into assembly and tweak for performance.
