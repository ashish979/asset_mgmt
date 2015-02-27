// this.PageSpinner = {
//   spin: function(ms) {
//     var _this = this;
//     if (ms == null) {
//       ms = 150;
//     }
//     this.spinner = setTimeout((function() {
//       return _this.add_spinner();
//     }), ms);
//     return $(document).on('page:change', function() {
//       return _this.remove_spinner();
//     });
//   },

//   spinner: null,
//   add_spinner: function() {
//     showProgress();
//   },
//   remove_spinner: function() {
//     clearTimeout(this.spinner);
//     endProgress();
//   }
// };
 
// $(document).on('page:fetch', function() {
//   return PageSpinner.spin();
// });
