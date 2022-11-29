复合协议
  Compound 协议是用于提供或借入资产的以太坊智能合约。通过 cToken 合约，区块链上的账户提供资金（以太币或 ERC-20 代币）以接收 cToken 或从协议中借入资产（持有其他资产作为抵押品）。Compound cToken 合约跟踪这些余额并通过算法为借款人设定利率。

合约
  我们详细介绍了 Compound 协议中的一些核心合约。

CToken、CErc20 和 CEther
  Compound cTokens，是独立的借贷合约。CToken 包含核心逻辑，CErc20 和 CEther 分别为 Erc20 代币和以太币添加公共接口。
  每个 CToken 都被分配了一个利率和风险模型（参见 InterestRateModel 和 Comptroller 部分），并允许账户*铸造*（供应资本）、*赎回*（提取资本）、*借入*和*偿还借入*。每个 CToken 都是符合 ERC-20 标准的代币，其中余额代表市场所有权。

Comptroller
  风险模型合同，它验证允许的用户操作并在不符合某些风险参数时禁止操作。例如，审计员强制每个借款用户必须在所有 cToken 中保持足够的抵押品余额。

  Updating the Comptroller
    遵循现有的命名模式 (ControllerGX)
    在 scenario/src/Builder/ComptrollerImplBuilder.ts 中更新场景运行器
    根据需要创建单元测试和分叉模拟
    调用npx saddle deploy Comptroller -n mainnet部署到主网并生成新的 ABI
    ABI 也可以通过在分叉模拟中部署到主网来生成
    调用node script/comptroller-abi 合并新的 Comptroller ABI 和 Unitroller ABI
    确保提交包含新生成的 Comptroller ABI

Comp
  复合治理令牌（COMP）。该令牌的持有者能够通过治理者合约来治理协议。

Governor Alpha
  Compound 时间锁合约的管理员。Comp 代币的持有者可以创建提案并对其进行投票，这些提案将排队进入 Compound 时间锁，然后对 Compound cToken 和 Comptroller 合约产生影响。将来可能会用测试版替换此合约。

InterestRateModel
  定义利率模型的合同。这些模型根据给定市场的当前利用率（即提供的资产中有多少是流动的与借来的）通过算法确定利率。

Careful Math
  Library for safe math operations.

ErrorReporter
  用于跟踪错误代码和故障条件的库。

Exponential
  用于处理定点十进制数的库。

SafeToken
  用于安全处理 Erc20 交互的库。

WhitePaperInterestRateModel
  白皮书中定义的初始利率模型。该合约在其构造函数中接受基本利率和斜率参数。

安装
  要运行 compound，请从 GitHub 拉取存储库并安装其依赖项。您将需要安装yarn或npm。

  git clone https://github.com/compound-finance/compound-protocol
  cd compound-protocol
  yarn install --lock-file # or `npm install`


REPL
  复合协议有一个简单的场景评估工具来测试和评估区块链上可能发生的场景。这主要用于构建高级集成测试。该工具还有一个 REPL 可以与本地 Compound Protocol（类似于truffle console）进行交互。

  yarn repl -n development
  yarn repl -n rinkeby

  > Read CToken cBAT Address
  Command: Read CToken cBAT Address
  AddressV<val=0xAD53863b864AE703D31b819d29c14cDA93D7c6a6>


测试
  Jest 合约测试定义在tests 目录下。要运行测试运行：

yarn test
  集成规范
  spec/scenario文件夹下还有其他测试。这些是基于上述场景运行器的高级集成测试。这些测试的目的是高度识字并在合同交互中具有高覆盖率。

形式验证规范
  复合协议有许多形式验证规范，由Certora提供支持。您可以在spec/formal文件夹中找到详细信息。包含的 Certora 验证语言 (CVL) 文件是规范，当使用 Certora CLI 工具时，它会生成正式证明（或反例），证明给定合约的代码与该规范完全匹配。

代码覆盖率
  要运行代码覆盖率，请运行：


