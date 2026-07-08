def compute(values):
    total = 0
    for v in values:
        if v > 0:
            total += v
        elif v < 0:
            total -= v
        else:
            continue
    return total


def risky():
    try:
        data = {
            "key": 1,
            "other": 2,
        }
    except ValueError:
        raise
    finally:
        pass
    return (
        data
    )


def dispatch(command):
    match command:
        case "quit":
            return 0
        case _:
            return 1
