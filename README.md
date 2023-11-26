# SO-Team #1

## Task 1
Given that a floppy disk is divided into 96 logical blocks with 30 sectors each, and each block has 15360 bytes, we can calculate the track, sector, and head for the given sector start and sector end.

First, let’s calculate the total number of sectors per track. A standard 1.44MB floppy disk has 18 sectors per track and 2 heads (sides). So, the total number of sectors per track is 18 sectors/track * 2 heads = 36 sectors/track.

Now, let’s calculate the track, sector, and head for the sector start (1951) and sector end (1980).

For sector start (1951):

    Track = 1951 / 36 = 54
    Head = (1951 % 36) / 18 = 0
    Sector = (1951 % 36) % 18 + 1 = 7

For sector end (1980):

    Track = 1980 / 36 = 55
    Head = (1980 % 36) / 18 = 0
    Sector = (1980 % 36) % 18 + 1 = 6

So, to write to the floppy disk at sector start (1951), you would use track 54, head 0, and sector 7. And to write at sector end (1980), you would use track 55, head 0, and sector 6.