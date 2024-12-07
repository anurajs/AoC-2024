from dataclasses import dataclass


@dataclass
class Problem:
    target: int
    operands: list[int]


def isSolvable(problem: Problem) -> bool:
    if problem.operands[0] > problem.target:
        return False
    if len(problem.operands) == 1 and problem.operands[0] == problem.target:
        return True
    elif len(problem.operands) == 1 and problem.operands[0] != problem.target:
        return False
    return (
        isSolvable(
            Problem(
                problem.target,
                [problem.operands[0] + problem.operands[1]] + problem.operands[2:],
            )
        )
        or isSolvable(
            Problem(
                problem.target,
                [problem.operands[0] * problem.operands[1]] + problem.operands[2:],
            )
        )
        or isSolvable(
            Problem(
                problem.target,
                [int(str(problem.operands[0]) + str(problem.operands[1]))]
                + problem.operands[2:],
            )
        )
    )


problems: list[Problem] = []
with open("./problems/day7.txt", "r") as file:
    for line in file.readlines():
        split = line.split(": ")
        target = int(split[0])
        operands = [int(x) for x in split[1].split(" ")]
        problems.append(Problem(target, operands))

sum = 0
for problem in problems:
    sum += problem.target if isSolvable(problem) else 0

print(sum)
