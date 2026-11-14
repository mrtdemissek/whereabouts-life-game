import 'package:flutter/material.dart';
import 'ses.dart';
import 'tema.dart';

// Oyun arayüzünün ortak parçaları: kalın çerçeveli panel ve basılınca
// gölgesine gömülen "oyun düğmesi".

// Krem zeminli, mürekkep çerçeveli, sert gölgeli panel
class OyunPanel extends StatelessWidget {
  final Widget child;
  final Color renk;
  final EdgeInsets padding;
  final double golge;
  final double kenar;
  final double yaricap;
  const OyunPanel({
    required this.child,
    this.renk = Renk.kagit,
    this.padding = const EdgeInsets.all(12),
    this.golge = 4,
    this.kenar = 3,
    this.yaricap = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: renk,
        border: Border.all(color: Renk.murekkep, width: kenar),
        borderRadius: BorderRadius.circular(yaricap),
        boxShadow: golge > 0
            ? [
                BoxShadow(
                  color: Renk.murekkep,
                  offset: Offset(0, golge),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

// Basınca aşağı inen, bırakınca kalkan kalın oyun düğmesi.
// Dokunma alanı en az 48 px.
class OyunDugme extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color renk;
  final double yukseklik;
  final double golge;
  final String? anlam; // ekran okuyucu için etiket
  const OyunDugme({
    required this.child,
    required this.onTap,
    this.renk = Renk.kagit,
    this.yukseklik = 56,
    this.golge = 4,
    this.anlam,
    super.key,
  });

  @override
  State<OyunDugme> createState() => _OyunDugmeState();
}

class _OyunDugmeState extends State<OyunDugme> {
  bool _basili = false;

  void _bas(bool v) {
    if (widget.onTap == null) return;
    setState(() => _basili = v);
  }

  @override
  Widget build(BuildContext context) {
    final inis = _basili ? widget.golge : 0.0;
    return Semantics(
      button: true,
      label: widget.anlam,
      enabled: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _bas(true),
        onTapCancel: () => _bas(false),
        onTapUp: (_) => _bas(false),
        onTap: widget.onTap == null
            ? null
            : () {
                Ses.ornek.titret(TitresimTuru.hafif);
                widget.onTap!();
              },
        child: SizedBox(
          height: widget.yukseklik + widget.golge,
          child: Padding(
            padding: EdgeInsets.only(top: inis),
            child: Opacity(
              opacity: widget.onTap == null ? 0.5 : 1,
              child: Container(
                height: widget.yukseklik,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.renk,
                  border: Border.all(color: Renk.murekkep, width: 3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Renk.murekkep,
                      offset: Offset(0, widget.golge - inis),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
