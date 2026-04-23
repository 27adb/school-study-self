# ========== 自习室表 ==========
create table room
(
    id         int primary key auto_increment,
    name       varchar(100) not null comment '名称',
    image      varchar(100) not null comment '图片',
    location   varchar(100) not null comment '位置',
    rows_count int          not null comment '行数',
    cols_count int          not null comment '列数',
    open_time  time         not null comment '开放时间',
    close_time time         not null comment '关闭时间',
    status     varchar(10)  not null comment '状态'
) comment '自习室表';

# ========== 自习室座位表 ==========
create table room_seat
(
    id       int primary key auto_increment,
    seat_num varchar(10) not null comment '座位号',
    room_id  int         not null comment '自习室ID',
    row_num  int         not null comment '行号',
    col_num  int         not null comment '列号',
    status   int         not null comment '状态'
) comment '自习室座位表';

# ========== 自习室预约表 ==========
create table room_reservation
(
    id                   int primary key auto_increment,
    user_id              int          not null comment '用户ID',
    seat_id              int          not null comment '座位ID',
    status               varchar(10)  not null comment '状态',
    reservation_status   varchar(10)  not null comment '预约状态',
    reservation_in_time  datetime     not null comment '预约开始时间',
    reservation_out_time datetime     not null comment '预约结束时间',
    sign_in_time         datetime     null comment '签到时间',
    sign_out_time        datetime     null comment '签退时间',
    remark               varchar(100) null comment '备注'
) comment '自习室预约表';