/// Zimma AI — premium frosted bottom navigation.
///
/// A floating glass bar with an animated gradient "pill" that grows behind
/// the active tab (icon → icon+label). HCI: persistent wayfinding, clear
/// current-location signal, ≥48dp targets, tactile feedback via Pressable.

library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import 'pressable.dart';

class ZimmaNavItem {
  const ZimmaNavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class ZimmaBottomNav extends StatelessWidget {
  const ZimmaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ZimmaNavItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ZimmaTheme.radiusXl),
          child: BackdropFilter(
            filter: ZimmaTheme.blur,
            child: Container(
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ZimmaTheme.radiusXl),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.68),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                boxShadow: ZimmaTheme.elevation(3),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavCell(
                        item: items[i],
                        selected: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ZimmaNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: ZimmaTheme.motionBase,
          curve: ZimmaTheme.easeEmphasized,
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12),
          decoration: BoxDecoration(
            gradient: selected ? ZimmaTheme.primaryGradient : null,
            borderRadius: BorderRadius.circular(99),
            boxShadow: selected
                ? ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.35)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: 22,
                color: selected ? Colors.white : ZimmaTheme.textSecondary,
              ),
              AnimatedSize(
                duration: ZimmaTheme.motionBase,
                curve: ZimmaTheme.easeEmphasized,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
