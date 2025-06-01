# ruff: noqa: T201 ERA001 INP001

# Ensure type checking is enabled in your IDE

# add example showing difference between Generic func and func with union

from typing import Sequence, TypeVar, reveal_type

T = TypeVar("T")


# Generic func #1
def first(seq: Sequence[T]) -> T:
    return seq[0]


reveal_type(first([1, 2, 3]))
reveal_type(
    first(
        (
            "a",
            "b",
        )
    )
)


# Generic func #2
# def add_broken(a: int | str, b: int | str) -> int | str:
#     return a + b


def add[T: (int, str)](a: T, b: T) -> T:
    return a + b


add(1, 2)  # works
add("a", "b")  # works
# add(1, "a")  # fails, because T is bound to int | str


class Node[T]:
    def __init__(self, data: T) -> None:
        self.data = data
        self.next: Node[T] | None = None


class Queue[T]:
    def __init__(self) -> None:
        self.head: Node[T] | None = None
        self.tail: Node[T] | None = None
        self.length = 0

    def enqueue(self, data: T) -> None:
        n = Node(data)
        if self.tail:
            self.tail.next = n
        else:
            self.head = n

        self.tail = n
        self.length += 1

    def dequeue(self) -> T | None:
        if not self.head:
            return None

        res = self.head.data
        self.head = self.head.next

        if self.head is None:
            self.tail = None

        self.length -= 1

        return res

    def to_list(self) -> list[T]:
        res = []
        if self.length == 0:
            return res

        node = self.head
        while node is not None:
            res.append(node.data)
            node = node.next

        return res


# ---
generic_q = Queue[int]()

generic_q.enqueue(1)
generic_q.enqueue(2)
generic_q.enqueue(3)
generic_q.enqueue(4)
# generic_q.enqueue('abc')

print("Generic int queue")
while (val := generic_q.dequeue()) is not None:
    print(val)


# ---
# Before 3.12

# from typing import Generic, TypeVar
# T = TypeVar("T", bound=(float | int))
# class NumericQueue(Generic[T], Queue[T]):


# T: (float, int) != T: float | int.
class NumericQueue[T: (float, int)](Queue[T]):
    @property
    def total(self) -> T:
        current_sum = 0
        node = self.head

        while node:
            current_sum += node.data
            node = node.next

        return current_sum


numeric_q = NumericQueue[int]()

numeric_q.enqueue(2.3)  # highlighted with as type violation
numeric_q.enqueue(2)
print(f"\nNumeric int queue: {numeric_q.to_list()} | Total: {numeric_q.total}")


# ---
class MyFloat(float): ...


numeric_q = NumericQueue[MyFloat]()

numeric_q.enqueue(2.3)
# the line below is not a type violation, because int in Python typing is a covariance of float
numeric_q.enqueue(2)
print(f"\nNumeric float queue: {numeric_q.to_list()} | Total: {numeric_q.total}")

# ---
numeric_q = NumericQueue[str]()
numeric_q.enqueue("abc")  # doesn't fail, interpreter doesn't care about types
print(f"\nNumeric str queue: {numeric_q.to_list()}")
# print(f"Numeric str total: {numeric_q.total}") # fails because we have a string in queue


# --- Legacy vs Modern TypeAlias syntax Python 3.12+
# from typing import TypeAlias

# _T = TypeVar("_T")

# ListOrSet: TypeAlias = list[_T] | set[_T]

# type ListOrSetNew[T] = list[T] | set[T]
