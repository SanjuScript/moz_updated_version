import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/Widgets/custom_switch.dart';

class ControlsSection extends StatelessWidget {
  final bool isTransliterating;
  final String? selectedLanguageLabel;
  final bool showTimestamps;
  final bool canSave;

  final VoidCallback onPickLanguage;
  final ValueChanged<bool> onToggleTimestamps;
  final VoidCallback onSave;

  const ControlsSection({
    super.key,
    required this.isTransliterating,
    required this.selectedLanguageLabel,
    required this.showTimestamps,
    required this.canSave,
    required this.onPickLanguage,
    required this.onToggleTimestamps,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Language picker
          _RoundTile(
            isDark: isDark,
            onTap: isTransliterating ? null : onPickLanguage,
            leading: Icon(
              Icons.translate,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            title: selectedLanguageLabel == null
                ? 'Convert to Manglish'
                : '$selectedLanguageLabel → Manglish',
            subtitle: selectedLanguageLabel != null
                ? 'Tap to change language'
                : null,
            trailing: isTransliterating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.chevron_right, color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          // Timestamps toggle + Save
          Row(
            children: [
              Expanded(
                child: _RoundTile(
                  isDark: isDark,
                  onTap: () => onToggleTimestamps(!showTimestamps),
                  leading: Icon(
                    Icons.text_fields,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  title: 'Show Timestamps',
                  trailing: CustomSwitch(
                    value: showTimestamps,
                    onChanged: onToggleTimestamps,
                  ),
                ),
              ),
              if (canSave) ...[
                const SizedBox(width: 12),
                _SaveButton(onTap: onSave),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  final bool isDark;
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _RoundTile({
    required this.isDark,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : Colors.black.withValues(alpha: .03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: .05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: leading,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: .8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: .3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.save_outlined, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
