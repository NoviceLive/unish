#!/usr/bin/env python3


from time import perf_counter, sleep


def main():
    while True:
        try:
            print('{} {:.2f} KiB/s {} {:.2f} KiB/s\r'.format(
                chr(8595), get_speed(),
                chr(8593), get_speed(True)), end='')
        except KeyboardInterrupt:
            break


def get_speed(upload=False):
    old_time = perf_counter()
    old_number = read_statistics(upload)
    sleep(0.5)
    new_number = read_statistics(upload)
    new_time = perf_counter()
    interval = new_time - old_time
    total_number = new_number - old_number
    kili = (total_number) / interval / 1024
    return kili


def read_statistics(trans=False):
    name = 'tx_bytes' if trans else 'rx_bytes'
    path = '/sys/class/net/wlp3s0/statistics/' + name
    with open(path) as stream:
        value = stream.read()
    return int(value)


if __name__ == '__main__':
    main()
