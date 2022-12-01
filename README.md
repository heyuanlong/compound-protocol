复合协议
  Compound 协议是用于提供或借入资产的以太坊智能合约。通过 cToken 合约，区块链上的账户提供资金（以太币或 ERC-20 代币）以接收 cToken 或从协议中借入资产（持有其他资产作为抵押品）。Compound cToken 合约跟踪这些余额并通过算法为借款人设定利率。

合约
  我们详细介绍了 Compound 协议中的一些核心合约。

CToken、CErc20 和 CEther
  Compound cTokens，是独立的借贷合约。CToken 包含核心逻辑，CErc20 和 CEther 分别为 Erc20 代币和以太币添加公共接口。
  每个 CToken 都被分配了一个利率和风险模型（参见 InterestRateModel 和 Comptroller 部分），并允许账户*铸造*（供应资本）、*赎回*（提取资本）、*借入*和*偿还借入*。每个 CToken 都是符合 ERC-20 标准的代币，其中余额代表市场所有权。

Comptroller-审计员
  风险模型合同 ，它验证允许的用户操作并在不符合某些风险参数时禁止操作。例如，审计员强制每个借款用户必须在所有 cToken 中保持足够的抵押品余额。

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
  定义利率模型的合同。 这些模型根据给定市场的当前利用率（即提供的资产中有多少是流动的与借来的）通过算法确定利率。

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




兑换率是怎么增加的？
  兑换率依照以下数据做计算(以Compound DAI为例子)：
  totalCash =放入智能合约，但还没被借走DAI的总数量
  totalBorrows =所有借款人，所应偿还DAI的总数量(含本金利息)
  totalReserves =保留金总数量(借款人所应支付的利息，部分被视为保留金)
  totalSupply =所有放贷人所得到cDAI的总数量

  exchangeRate = (totalCash + totalBorrows - totalReserves) / totalSupply



借款年利率
  在Compound 利率模型里，会计算借款年利率，这个利率会受到以下因素影响：

  基础利率(base rate)
  使用率(utilization rate) = totalBorrows/(totalCash + totalBorrows)
  加给利率(multiplier)
  借款年利率= 基础利率+ (使用率x 加给利率)

  以Compound DAI为例，基础利率= 5%，加给利率= 12%，若以目前当下的使用率= 62.13%来计算：
  借款年利率 = 5% + (12% x 0.6213) = 12.4556%


放贷年利率
  放贷年利率同样会受到以下因素影响：

  借款年利率(borrow rate) (上述所计算出来的)
  使用率(utilization rate)
  保留利率(reserve factor)
  放贷年利率≈ 借款年利率x 使用率x (1 – 保留利率)

  同样以Compound DAI为例子，上述算出借款年利率 = 12.46%，使用率=62.13%，保留利率 = 5%
  放贷年利率 ≈ 12.46% x 62.13% x (1 – 5%) = 12.46% x 0.6213 x 0.95 = 7.3543281%



标的资产（Underlying Token）：
  即借贷资产，比如 ETH、USDT、USDC、WBTC 等，目前 Compound 只开设了 14 种标的资产。
  cToken：也称为生息代币，是用户在 Compound 上存入资产的凭证。每一种标的资产都有对应的一种 cToken，比如，ETH 对应 cETH，USDT 对应 cUSDT，当用户向 Compound 存入 ETH 则会返回 cETH。取款时就可以用 cToken 换回标的资产。

兑换率（Exchange Rate）：
  cToken 与标的资产的兑换比例，比如 cETH 的兑换率为 0.02，即 1 个 cETH 可以兑换 0.02 个 ETH。
  兑换率会随着时间推移不断上涨，因此，持有 cToken 就等于不断生息，所以也才叫生息代币。
  计算公式为：exchangeRate = (totalCash + totalBorrows - totalReserves) / totalSupply

抵押因子（Collateral Factor）：
  每种标的资产都有一个抵押因子，代表用户抵押的资产价值对应可得到的借款的比率，即用来衡量可借额度的。取值范围 0-1，当为 0 时，表示该类资产不能作为抵押品去借贷其他资产。一般最高设为 0.75，比如 ETH，假如用户存入了 0.1 个 ETH 并开启作为抵押品，当时的 ETH 价值为 2000 美元，则可借额度为 0.1 * 2000 * 0.75 = 150 美元，可最多借出价值 150 美元的其他资产。



涉及核心业务的其实可以分为四个模块：
  1.InterestRateModel：
    利率模型的抽象合约，JumpRateModelV2、JumpRateModel、WhitePaperInterestRateModel 都是具体的利率模型实现。而 LegacyInterestRateModel 的代码和 InterestRateModel 相比，除了注释有些许不同，并没有其他区别。
  2.Comptroller：
    审计合约，封装了全局使用的数据，以及很多业务检验功能。其入口合约为 Unitroller，也是一个代理合约。
  3.PriceOracle：
    价格预言机合约，用来获取资产价格的。
  4.CToken：
    cToken 代币的核心逻辑实现都在该合约中，属于抽象基类合约，没有构造函数，且定义了 3 个抽象函数。CEther 是 cETH 代币的入口合约，直接继承自 CToken。而 ERC20 的 cToken 入口则是 CErc20Delegator，这是一个代理合约，而实际实现合约为 CErc20Delegate 或 CCompLikeDelegate、CDaiDelegate 等。



直线型
  具体的利率模型实现有好几个，WhitePaperInterestRateModel 是最简单的一种实现.

  资金使用率 = 总借款 / (资金池余额 + 总借款 - 储备金)
  utilizationRate = borrows / (cash + borrows - reserves)
  
  存款利率 = 资金使用率 * 借款利率 *（1 - 储备金率）
  supplyRate = utilizationRate * borrowRate * (1 - reserveFactor)


拐点型
  拐点型主要有过两个版本的实现，JumpRateModel 和 JumpRateModelV2，目前，曾经使用 JumpRateModel 的都已经升级为 JumpRateModelV2.

  资金使用率没超过拐点值时，利率公式和直线型的一样：
    y = k*x + b
  而超过拐点之后，则利率公式将变成：
    y = k2*(x - p) + (k*p + b)


https://learnblockchain.cn/people/96
简而言之，ETH 的 cToken 交互入口是 CEther 合约，仅此一份；而 ERC20 的 cToken 交互入口则是 CErc20Delegator 合约，每种 ERC20 资产都各有一份入口合约。


存取借款等核心业务的入口函数则主要有以下几个：
    mint：存款，之所以叫 mint，是因为该操作会新增 cToken 数量，即 totalSupply 增加了，就等于挖矿了 cToken。该操作会将用户的标的资产转入 cToken 合约中（数据会存储在代理合约中），并根据最新的兑换率将对应的 cToken 代币转到用户钱包地址。
    redeem：赎回存款，即用 cToken 换回标的资产，会根据最新的兑换率计算能换回多少标的资产。
    redeemUnderlying：同样是赎回存款的函数，与上一个函数不同的是，该函数指定的是标的资产的数量，会根据兑换率算出需要扣减多少 cToken。
    borrow：借款，会根据用户的抵押物来计算可借额度，借款成功则将所借资产从资金池中直接转到用户钱包地址。
    repayBorrow：还款，当指定还款金额为 -1 时，则表示全额还款，包括所有利息，否则，则会存在利息没还尽的可能，因为每过一个区块就会产生新的利息。
    repayBorrowBehalf：代还款，即支付人帮借款人还款。
    liquidateBorrow：清算，任何人都可以调用此函数来担任清算人，直接借款人、还款金额和清算的 cToken 资产，清算时，清算人帮借款人代还款，并得到借款人所抵押的等值+清算奖励的 cToken 资产。

以上，每一步操作发生时，都会调用 accrueInterest() 函数计算新的利息。该函数的实现逻辑主要如下：

  -获取当前区块 crrentBlockNumber 和最近一次计算的区块 accrualBlockNumberPrior，如果两个区块相等，表示当前区块已经计算过利息，无需再计算，直接返回。
  -获取保存的 cash（资金池余额）、totalBorrows（总借款）、totalReserves（总储备金）、borrowIndex（借款指数）。
  -调用 interestRateModel.getBorrowRate() 得到借款利率 borrowRate。
  -如果 borrowRate 超过最大的借款利率，则错误退出，否则进入下一步。
  -计算当前区块和 accrualBlockNumberPrior 之间的区块数 blockDelta，该区块数即是还未计算利息的区块区间。
  -根据以下公式计算出新累积的利息和一些新值：
    simpleInterestFactor = borrowRate * blockDelta，区块区间内的单位利息
    interestAccumulated = simpleInterestFactor * totalBorrows，表示总借款在该区块区间内产生的总利息
    totalBorrowsNew = interestAccumulated + totalBorrows，将总利息累加到总借款中
    totalReservesNew = interestAccumulated * reserveFactor + totalReserves，根据储备金率将部分利息累加到储备金中
    borrowIndexNew = simpleInterestFactor * borrowIndex + borrowIndex，累加借款指数

  更新以下值：
    accrualBlockNumber = currentBlockNumber
    borrowIndex = borrowIndexNew
    totalBorrows = totalBorrowsNew
    totalReserves = totalReservesNew
