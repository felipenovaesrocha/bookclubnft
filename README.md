# Book Club NFT

### Explicação do contrato por GPT

Este contrato é um exemplo de como implementar um contrato ERC1155 com metadados armazenados no contrato e suporte para a emissão de dois tipos de NFTs: um exclusivo da Bankless e um que representa a leitura de um livro.

O contrato importa as seguintes bibliotecas do OpenZeppelin:

ERC1155Upgradeable: implementação do padrão ERC1155 de tokens não fungíveis;
ERC1155URIStorageUpgradeable: implementação do armazenamento de metadados dos tokens ERC1155 em uma estrutura de dados URI;
OwnableUpgradeable: implementação de um contrato que tem um dono, que é capaz de executar certas funções exclusivas para o dono;
Initializable: um contrato pode ser inicializado com o método initialize().
O contrato define algumas constantes que representam o tipo de cada NFT, incluindo o BANKLESS_EXCLUSIVE_NFT e o BOOK_NFT_RANGE_START e BOOK_NFT_RANGE_END, que determinam o intervalo dos tipos de NFTs de livros.

A função initialize() é usada para inicializar o contrato com o construtor da biblioteca.

A função setURI() é usada para atualizar a URI de um token especificado por tokenId.

As funções mintExclusiveNFT_owner() e \_mintExclusiveNFT() são usadas para emitir um NFT exclusivo da Bankless para um endereço especificado pelo dono do contrato.

A função mintBanklessExclusiveNFT() é usada para permitir que qualquer endereço emita um NFT exclusivo da Bankless.

A função mintBookNFT() é usada para emitir um NFT de livro para um endereço especificado pelo dono do contrato. É necessário fornecer um ID de livro válido como argumento.

A função uri() é usada para obter a URI de um token especificado pelo tokenId.

Esse contrato pode ser usado como base para desenvolver um sistema de emissão de NFTs personalizado.

### Documentação do contrato BookClubNFT

Variáveis
BANKLESS_EXCLUSIVE_NFT: Valor constante utilizado para representar o NFT exclusivo da Bankless.

BOOK_NFT_RANGE_START: Valor constante que representa o início do range de IDs para os NFTs de livros.

BOOK_NFT_RANGE_END: Valor constante que representa o fim do range de IDs para os NFTs de livros.

\_claimedBookNFTs: Um mapping que armazena se um endereço já reivindicou um determinado NFT de livro. É indexado pelo endereço e pelo ID do livro.

\_bookMerkleRoots: Um mapping que armazena a raiz de Merkle trees para cada ID de livro. É indexado pelo ID do livro.

Eventos
ExclusiveNFTMinted: Evento emitido quando um NFT exclusivo da Bankless é emitido para um endereço.

BookNFTMinted: Evento emitido quando um NFT de livro é emitido para um endereço.

Funções
initialize(): Função utilizada na inicialização do contrato. Inicializa o contrato pai ERC1155 e o contrato de controle de propriedade Ownable.

setURI(uint256 tokenId, string memory tokenURI): Permite ao proprietário do contrato atualizar o URI de um determinado token.

mintExclusiveNFT_owner(address to): Função utilizada pelo proprietário do contrato para emitir um NFT exclusivo da Bankless para um endereço específico.

mintBanklessExclusiveNFT(): Função utilizada para que um endereço possa emitir um NFT exclusivo da Bankless para si mesmo.

mintBookNFT(address to, uint256 bookId): Função utilizada pelo proprietário do contrato para emitir um NFT de livro para um endereço específico.

uri(uint256 tokenId): Função utilizada para obter o URI de um determinado token.

mintBookNFT(uint256 bookId, bytes32[] calldata proof): Função utilizada para que um endereço possa emitir um NFT de livro para si mesmo, utilizando um Merkle proof.

setBookMerkleRoot(uint256 bookId, bytes32 merkleRoot): Permite ao proprietário do contrato atualizar a raiz do Merkle tree para um determinado ID de livro.

setClaimedBookNFTs(address to, uint256 bookId, bool value): Permite ao proprietário do contrato atualizar se um determinado endereço já reivindicou um NFT de livro específico.
