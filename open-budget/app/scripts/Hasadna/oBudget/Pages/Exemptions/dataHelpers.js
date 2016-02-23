import _ from 'underscore';
import parentMinistriesVariants from 'Hasadna/oBudget/Pages/Exemptions/parentMinistriesVariants';
import moment from 'vendor/moment';

class dataHelpers {
  static composeExemptionsSortFunc(controlsValues) {
    return (ex1, ex2) => {
      let ret = true;
      const exemption1 = ex1;
      const exemption2 = ex2;

      switch (controlsValues.orderBy) {
        case 'total_flags':
          if (!exemption1.flags) {
            exemption1.flags = {
              total_flags: 0,
            };
          }
          if (!exemption2.flags) {
            exemption2.flags = {
              total_flags: 0,
            };
          }
          break;

        case 'date':
          ret = (exemption1.last_update_date.getTime() || 0) >
            (exemption2.last_update_date.getTime() || 0);
          break;

        case 'volume':
          ret = exemption1.volume > exemption2.volume;
          break;

        default:
          ret = exemption1.flags.total_flags > exemption2.flags.total_flags;
      }

      if (ret) {
        return -1 * controlsValues.orderByDirection;
      }

      return 1 * controlsValues.orderByDirection;
    };
  }

  static composeExemptionsFilterFunc(controlsValues, ministriesAliasesIndex) {
    let filterByMinistry = false;
    let localIndex;

    if (controlsValues.ministry.length > 0) {
      // build list of possible ministreis branches
      localIndex = _.pick(ministriesAliasesIndex, controlsValues.ministry);

      localIndex = _.values(localIndex);
      localIndex = _.flatten(localIndex);
      filterByMinistry = true;
    }

    return (exemption) => {
      const timeFrameStart = moment().subtract(controlsValues.timeFrame, 'days').valueOf();

      if (!(exemption.get('last_update_date').getTime() > timeFrameStart)) {
        return false;
      }

      if (filterByMinistry && !(localIndex.indexOf(exemption.get('publisher')) > -1)) {
        return false;
      }
      // textSearchFields = [
      // ]
      // free text here, by what fields ?
      // ret = ret and !controlsValues.freeText or
      // @freeTextFilter controlsValues.freeText, exemption
      return true;
    };
  }

  static generateAliasesIndex(ministriesWithDepartments) {
    const aliasesIndex = _.object(_.keys(parentMinistriesVariants), []);
    let withDepartments = ministriesWithDepartments;

    _.each(aliasesIndex, (stub, ministry) => {
      aliasesIndex[ministry] = [ministry];
      return _.each(ministriesWithDepartments, (rawMinistry, i) => {
        parentMinistriesVariants[ministry].forEach((ministryVariant) => {
          if (rawMinistry.indexOf(ministryVariant) > -1) {
            aliasesIndex[ministry].push(rawMinistry);
            // mark this entry as matched
            withDepartments[i] = '---matched---';
          }
        });
      });
    });

    // if there is records in ministriesWithDepartments
    // that don't match any parentMinistriesVariants
    // Add them as separate entries in the index
    withDepartments = ministriesWithDepartments
      .filter((rawMinistry) => rawMinistry !== '---matched---');

    _.each(withDepartments, (rawMinistry) => {
      aliasesIndex[rawMinistry] = [rawMinistry];
    });

    return aliasesIndex;
  }

  static generateAliasesMap(ministriesWithDepartments) {
    const aliasesMap = _.object(ministriesWithDepartments, ministriesWithDepartments);

    return _.mapObject(aliasesMap, dataHelpers.getMinistryForMinistryVariant);
  }

  static getMinistryForMinistryVariant(ministryVariant) {
    let matched = null;

    _.each(parentMinistriesVariants, (variantsArray, ministry) => {
      if (matched) {
        return;
      }

      variantsArray.forEach((variantFragment) => {
        if ((ministryVariant.indexOf(variantFragment)) > -1) {
          matched = ministry;
        }
      });
    });

    if (!matched) {
      matched = ministryVariant;
    }

    return matched;
  }

  // static getExemptionsExportUrl(exemptions) {
  //   var url;
  //   var exs = exemptions.map(function (e) {
  //     e = _.omit(e, ['flags']);
  //     return _.mapObject(e, function (f) {
  //       if (f instanceof Date) {
  //         return moment(f).format();
  //       } else {
  //         return f;
  //       }
  //     });
  //   });
  //   var strView = new StringView(papaparse.unparse(exs), 'UTF-16');
  //   return url = URL.createObjectURL(new Blob([strView.buffer], {
  //     'type': 'text/csv;charset=UTF-16'
  //   }));
  // }

  // static getSupportsExportUrl(supports) {
  //   var url;
  //   var strView = new StringView(papaparse.unparse(supports), 'UTF-16');
  //   return url = URL.createObjectURL(new Blob([strView.buffer], {
  //     'type': 'text/csv;charset=UTF-16'
  //   }));
  // }
}

export default dataHelpers;
