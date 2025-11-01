# 궁극적으로 필요한 DSL

내가 원하는 DSL(Domain-Specific Language) Ｌ은 다음 성질을 만족한다.

1. Ｌ의 모든 Expression 에 Dijkstra Monad 연산을 적용해 Verification conditions(*1*) 을 구할 수 있어야 한다.
2. 모든 (*1*)을 Ｌ로 표현할 수 있어야 한다.
3. Ｌ의 모든 Evaluation 이 Terminate 함을 증명할 수 있어야 한다.
