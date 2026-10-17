// ==============================================================================
// MACRO HIỂN THỊ TRẠNG THÁI & GIẢI MÃ BÁO ĐỘNG HỆ THỐNG SẤY UV (FX2N_UV_ST)
// ÁP DỤNG TRÊN WEINTEK EASYBUILDER PRO (CHU KỲ QUÉT: 100ms)
// ==============================================================================

macro_command main()
    short machineState = 0
    short activeAlarmCode = 0
    short powerWatt = 0
    short coolDownSec = 0
    bool bMasterAlarm = 0
    bool bBuzzer = 0
    bool bDoorSafe = 0
    char szStateText[32] = ""
    char szAlarmText[64] = ""

    // 1. Đọc dữ liệu từ PLC FX2N qua driver Mitsubishi FX0n/FX2n
    GetData(machineState, "FX2N_UV", D, 100, 1)
    GetData(activeAlarmCode, "FX2N_UV", D, 101, 1)
    GetData(powerWatt, "FX2N_UV", D, 103, 1)
    GetData(coolDownSec, "FX2N_UV", D, 105, 1)
    GetData(bMasterAlarm, "FX2N_UV", Y, 0, 1)
    GetData(bBuzzer, "FX2N_UV", Y, 1, 1)
    GetData(bDoorSafe, "FX2N_UV", M, 189, 1)

    // 2. Chuyển đổi trạng thái máy sang Text hiển thị trên Banner HMI
    switch machineState
        case 0:
            StringCopy("HỆ THỐNG ĐANG DỪNG (OFF)", szStateText)
            break
        case 1:
            StringCopy("MỒI HỒ QUANG 80W (WARM-UP)", szStateText)
            break
        case 2:
            StringCopy("SẴN SÀNG SẤY (STANDBY)", szStateText)
            break
        case 3:
            StringCopy("ĐANG SẤY TIÊU CHUẨN (120W)", szStateText)
            break
        case 4:
            StringCopy("SẤY TỐC ĐỘ CAO (160W TURBO)", szStateText)
            break
        case 5:
            StringCopy("ĐANG LÀM MÁT (AFTER-COOL)", szStateText)
            break
        case 6:
            StringCopy("DỪNG SỰ CỐ AN TOÀN (FAULT)", szStateText)
            break
        default:
            StringCopy("TRẠNG THÁI KHÔNG XÁC ĐỊNH", szStateText)
            break
    end switch

    // 3. Giải mã chi tiết mã số lỗi 1..9 sang Tiếng Việt có dấu
    switch activeAlarmCode
        case 0:
            StringCopy("HỆ THỐNG AN TOÀN - KHÔNG CÓ LỖI", szAlarmText)
            break
        case 1:
            StringCopy("E01: LỖI ĐIỆN ÁP BALLAST (QUÁ ÁP / SỤT ÁP)", szAlarmText)
            break
        case 2:
            StringCopy("E02: LỖI QUÁ TẢI RƠ LE NHIỆT QUẠT HÚT", szAlarmText)
            break
        case 3:
            StringCopy("E03: LỖI MẤT ÁP SUẤT GIÓ BUỒNG SẤY", szAlarmText)
            break
        case 4:
            StringCopy("E04: HỞ CÔNG TẮC LIÊN ĐỘNG BUỒNG CHIẾU UV", szAlarmText)
            break
        case 5:
            StringCopy("E05: LỖI KẸT HÀNH TRÌNH ĐÓNG/MỞ SHUTTER", szAlarmText)
            break
        case 6:
            StringCopy("E06: LỖI MẤT DÒNG CHẢY NƯỚC LÀM MÁT (FLOW SW)", szAlarmText)
            break
        case 7:
            StringCopy("E07: NÚT DỪNG KHẨN CẤP E-STOP ĐANG NHẤN", szAlarmText)
            break
        case 8:
            StringCopy("E08: CỬA TỦ NGUỒN CAO ÁP BỊ HỞ (NGẮT KHẨN)", szAlarmText)
            break
        case 9:
            StringCopy("E09: LỖI MÁY LÀM LẠNH NƯỚC TUẦN HOÀN CHILLER", szAlarmText)
            break
        default:
            StringCopy("CẢNH BÁO SỰ CỐ BẤT THƯỜNG", szAlarmText)
            break
    end switch

    // 4. Ghi chuỗi Text và trạng thái xuống bộ nhớ nội bộ Weintek (Local HMI LW/LB)
    SetData(szStateText[0], "Local HMI", LW, 200, 32)
    SetData(szAlarmText[0], "Local HMI", LW, 300, 64)

    // Cập nhật biến hiển thị Multi-State Lamp (LW-10)
    // 0: OFF (Xám), 1: 80W (Vàng nhạt), 2: 120W (Cam), 3: 160W (Tím UV rực rỡ)
    short lampVisualState = 0
    if powerWatt >= 160 then
        lampVisualState = 3
    else if powerWatt >= 120 then
        lampVisualState = 2
    else if powerWatt >= 80 then
        lampVisualState = 1
    else
        lampVisualState = 0
    end if
    SetData(lampVisualState, "Local HMI", LW, 10, 1)

end macro_command
