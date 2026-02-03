// ============================================================================
// CCS APP - EXPORT SYSTEM (mirrors WAVTech pattern)
// ============================================================================
// Usage: import 'package:'package:ccs_app/export.dart';
// ============================================================================

export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// Icons
export 'package:iconsax_plus/iconsax_plus.dart';

// State management & navigation
export 'package:get/get.dart' hide MapExtension, Trans;
export 'package:get/get_navigation/src/root/get_material_app.dart';
export 'package:get/get_navigation/src/routes/transitions_type.dart';

// App configuration & routing
export 'app/constants/constants.dart';
export 'app/constants/ui_constants.dart';
export 'app/routes/app_pages.dart';

// Theme
export 'app/theme/theme.dart';
export 'app/theme/styles.dart';

// Utils
export 'app/utils/extension.dart';
export 'app/utils/validator.dart';
export 'app/utils/permission_utils.dart';
export 'app/utils/alerts.dart';
export 'app/utils/notifier.dart';
export 'app/utils/custom_loader.dart';
export 'app/utils/date_utils.dart';
export 'app/utils/secure_logger.dart';
export 'app/utils/error_handler.dart';

// Network helpers (result + unified exception mapper)
export 'app/network/utils/network_result.dart';
export 'app/network/utils/network_exception.dart';

// Widgets
export 'app/widget/common/avatar.dart';
export 'app/widget/common/cleaner_card.dart';
export 'app/widget/common/common_button.dart';
export 'app/widget/common/info_chip.dart';
export 'app/widget/common/label_value_row.dart';
export 'app/widget/common/text.dart';
export 'app/widget/common/text_field.dart';
export 'app/widget/layout/calendar_empty_card.dart';
export 'app/widget/layout/no_data_view.dart';
export 'package:ccs_app/app/widget/common/header.dart';
export 'package:ccs_app/app/widget/widgets.dart';
