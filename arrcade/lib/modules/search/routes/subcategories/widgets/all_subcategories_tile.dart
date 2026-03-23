import 'package:flutter/material.dart';
import 'package:arrcade/core.dart';
import 'package:arrcade/modules/search.dart';
import 'package:arrcade/router/routes/search.dart';

class SearchSubcategoryAllTile extends StatelessWidget {
  const SearchSubcategoryAllTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SearchState, NewznabCategoryData?>(
      selector: (_, state) => state.activeCategory,
      builder: (context, category, _) => LunaBlock(
        title: 'search.AllSubcategories'.tr(),
        body: [TextSpan(text: category?.name ?? 'arrcade.Unknown'.tr())],
        trailing: LunaIconButton(
            icon: context.read<SearchState>().activeCategory?.icon,
            color: LunaColours().byListIndex(0)),
        onTap: () async {
          context.read<SearchState>().activeSubcategory = null;
          SearchRoutes.RESULTS.go();
        },
      ),
    );
  }
}
