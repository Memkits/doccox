///|
pub struct Sample {
  name : String
  content : String
} derive(Eq)

///|
pub let samples : Array[Sample] = [
  {
    name: "JavaScript Demo",
    content: (
      #|// # JavaScript 演示
      #|//
      #|// 这个示例展示如何在浏览器中运行 JavaScript 代码片段。
      #|// 点击代码块中的 **▶ Run** 按钮即可执行。
      #|
      #|// ## 简单计算
      #|//
      #|// 用 `js.run` 标记的代码块可以直接运行：
      #|//
      #|// ```js.run
      #|// const nums = [1, 2, 3, 4, 5];
      #|// const sum = nums.reduce((a, b) => a + b, 0);
      #|// console.log("数组:", JSON.stringify(nums));
      #|// console.log("总和:", sum);
      #|// console.log("平均:", sum / nums.length);
      #|// ```
      #|
      #|function sum(arr) {
      #|  return arr.reduce((a, b) => a + b, 0);
      #|}
      #|
      #|// ## 字符串处理
      #|//
      #|// ```js.run
      #|// const words = ["Hello", "from", "Doccox!"];
      #|// console.log(words.join(" "));
      #|// console.log("单词数:", words.length);
      #|// const upper = words.map(w => w.toUpperCase());
      #|// console.log("大写:", upper.join(", "));
      #|// ```
      #|
      #|function joinWords(words) {
      #|  return words.join(" ");
      #|}
      #|
      #|// ## Fibonacci 数列
      #|//
      #|// 经典递推算法：
      #|//
      #|// ```js.run
      #|// function fib(n) {
      #|//   if (n <= 1) return n;
      #|//   return fib(n - 1) + fib(n - 2);
      #|// }
      #|// const result = Array.from({length: 10}, (_, i) => fib(i));
      #|// console.log("Fibonacci:", result.join(", "));
      #|// ```
      #|
      #|function fib(n) {
      #|  if (n <= 1) return n;
      #|  return fib(n - 1) + fib(n - 2);
      #|}
    ),
  },
  {
    name: "ECharts 图表",
    content: (
      #|// # ECharts 图表演示
      #|//
      #|// 使用 `json.echarts` 标记渲染交互式图表。
      #|// JSON 内容即为 ECharts 的 `option` 配置对象。
      #|
      #|// ## 柱状图
      #|//
      #|// 展示一周访问数据：
      #|//
      #|// ```json.echarts
      #|// {
      #|//   "title": { "text": "本周访问量" },
      #|//   "xAxis": { "data": ["周一","周二","周三","周四","周五","周六","周日"] },
      #|//   "yAxis": {},
      #|//   "series": [{ "type": "bar", "data": [820, 932, 901, 934, 1290, 1330, 1320] }]
      #|// }
      #|// ```
      #|
      #|const weekData = [820, 932, 901, 934, 1290, 1330, 1320];
      #|
      #|// ## 折线图
      #|//
      #|// 展示月度趋势：
      #|//
      #|// ```json.echarts
      #|// {
      #|//   "title": { "text": "月度趋势" },
      #|//   "xAxis": { "type": "category", "data": ["1月","2月","3月","4月","5月","6月"] },
      #|//   "yAxis": { "type": "value" },
      #|//   "series": [{
      #|//     "type": "line",
      #|//     "data": [150, 230, 224, 218, 135, 147],
      #|//     "smooth": true,
      #|//     "areaStyle": {}
      #|//   }]
      #|// }
      #|// ```
      #|
      #|const monthData = [150, 230, 224, 218, 135, 147];
      #|
      #|// ## 饼图
      #|//
      #|// 展示语言分布：
      #|//
      #|// ```json.echarts
      #|// {
      #|//   "title": { "text": "语言使用分布", "left": "center" },
      #|//   "series": [{
      #|//     "type": "pie",
      #|//     "radius": "60%",
      #|//     "data": [
      #|//       { "value": 35, "name": "MoonBit" },
      #|//       { "value": 25, "name": "JavaScript" },
      #|//       { "value": 20, "name": "Python" },
      #|//       { "value": 20, "name": "Other" }
      #|//     ]
      #|//   }]
      #|// }
      #|// ```
      #|
      #|const langData = [
      #|  { value: 35, name: "MoonBit" },
      #|  { value: 25, name: "JavaScript" },
      #|];
    ),
  },
  {
    name: "MoonBit 演示",
    content: (
      #|// # MoonBit 代码演示
      #|//
      #|// 这是一个演示示例，展示 MoonBit 代码风格。
      #|// 由于 MoonBit 暂未在浏览器内直接运行，
      #|// 点击运行按钮会显示预设的输出结果。
      #|
      #|// ## 数据结构
      #|//
      #|// 定义一个简单的树形结构：
      #|//
      #|// ```moonbit.demo
      #|// enum Tree[T] {
      #|//   Leaf(T)
      #|//   Node(Tree[T], T, Tree[T])
      #|// }
      #|//
      #|// fn sum_tree(t : Tree[Int]) -> Int {
      #|//   match t {
      #|//     Leaf(x) => x
      #|//     Node(l, x, r) => sum_tree(l) + x + sum_tree(r)
      #|//   }
      #|// }
      #|//
      #|// let tree = Node(Node(Leaf(1), 2, Leaf(3)), 4, Leaf(5))
      #|// println(sum_tree(tree))  // => 15
      #|// ```
      #|
      #|enum Tree[T] {
      #|  Leaf(T)
      #|  Node(Tree[T], T, Tree[T])
      #|}
      #|
      #|// ## 模式匹配
      #|//
      #|// MoonBit 的模式匹配非常强大：
      #|//
      #|// ```moonbit.demo
      #|// fn describe(n : Int) -> String {
      #|//   match n {
      #|//     0 => "zero"
      #|//     1..=9 => "single digit"
      #|//     10..=99 => "double digit"
      #|//     _ => "large number"
      #|//   }
      #|// }
      #|//
      #|// println(describe(0))   // => zero
      #|// println(describe(7))   // => single digit
      #|// println(describe(42))  // => double digit
      #|// println(describe(100)) // => large number
      #|// ```
      #|
      #|fn describe(n : Int) -> String {
      #|  match n {
      #|    0 => "zero"
      #|    1..=9 => "single digit"
      #|    10..=99 => "double digit"
      #|    _ => "large number"
      #|  }
      #|}
    ),
  },
  {
    name: "混合示例",
    content: (
      #|// # 混合渲染示例
      #|//
      #|// 这个示例综合演示所有扩展代码块类型。
      #|
      #|// ## 数据分析流程
      #|//
      #|// 首先用 JavaScript 生成数据：
      #|//
      #|// ```js.run
      #|// const data = Array.from({length: 12}, (_, i) => ({
      #|//   month: i + 1,
      #|//   sales: Math.floor(100 + Math.sin(i * 0.5) * 50 + i * 10)
      #|// }));
      #|// data.forEach(d => console.log(`${d.month}月: ${d.sales}`));
      #|// ```
      #|
      #|// ## 可视化结果
      #|//
      #|// 然后用 ECharts 展示趋势：
      #|//
      #|// ```json.echarts
      #|// {
      #|//   "title": { "text": "年度销售趋势" },
      #|//   "xAxis": { "data": ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"] },
      #|//   "yAxis": {},
      #|//   "series": [
      #|//     { "type": "line", "name": "销售额", "data": [100,125,132,149,158,175,178,199,211,230,246,260], "smooth": true },
      #|//     { "type": "bar", "name": "基准", "data": [80,80,80,80,80,80,80,80,80,80,80,80] }
      #|//   ],
      #|//   "legend": {}
      #|// }
      #|// ```
      #|
      #|// ## MoonBit 统计函数
      #|//
      #|// 对应的 MoonBit 实现：
      #|//
      #|// ```moonbit.demo
      #|// fn average(data : Array[Double]) -> Double {
      #|//   let sum = data.fold(init=0.0, (acc, x) => acc + x)
      #|//   sum / data.length().to_double()
      #|// }
      #|//
      #|// let sales = [100.0, 125.0, 132.0, 149.0, 158.0, 175.0]
      #|// println("平均值: \{average(sales)}")  // => 平均值: 139.833...
      #|// ```
      #|
      #|function average(data) {
      #|  return data.reduce((a, b) => a + b, 0) / data.length;
      #|}
    ),
  },
]
