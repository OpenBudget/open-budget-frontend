/*

	Grow – A microtemplating plugin for jQuery 1.9
	Version : 0.7.0
	Site	: http://armincifuentes.cl/grow
	
	Author	: Armin Cifuentes
	Company : Octano (http://octano.cl)
	License : GPLv3 / http://www.gnu.org/licenses/gpl.html

*/	
	
(function ($) {

	var methods = {
	
		init: function (options) {
			
			var d = {
				templateURL		: '',
				cache			: true,
				animation		: 'fade',
				speed			: 300,
				afterInsert		: function () {},
				beforeInsert	: function () {}
			};
						
			return this.each( function () {
				
				$(this).data('growSettings', $.extend(d,options) );
				
			});
			
		},
		
		append: function (params) {
			
			return this.each( function () {
			
				var settings	= $(this).data('growSettings'),
					result		= '',
					element		= this,
					speed		= settings.speed;
				
				if (typeof settings.beforeInsert == 'function' ) {
					settings.beforeInsert.call(this);
				}
				
				$.ajax({
					url:		settings.templateURL,
					cache:		settings.cache,
					dataType:	'html',
					success:	function (html) {
						
						result = methods.inject(html, params);
						
						switch (settings.animation) {
							case 'slide':
								result = $(result).slideDown(speed);
								break;

							case 'fade':
								result  = $(result).fadeIn(speed);
								break;

							default:
								result = result;
								break;
								
						}
						
						$(element).append(result);
						
					}
				});
				
			});
			
		},
		
		prepend: function (params) {
			return this.each( function () {
			
				var settings	= $(this).data('growSettings'),
					result		= '',
					element		= this,
					speed		= settings.speed;
				
				if (typeof settings.beforeInsert == 'function' ) {
					settings.beforeInsert.call(this);
				}
				
				$.ajax({
					url:		settings.templateURL,
					cache:		settings.cache,
					dataType:	'html',
					success:	function (html) {
						
						result = methods.inject(html, params);
						
						switch (settings.animation) {
							case 'slide':
								result = $(result).slideDown(speed);
								break;

							case 'fade':
								result  = $(result).fadeIn(speed);
								break;

							default:
								result = result;
								break;
								
						}
						
						$(element).prepend(result);
						
					}
				});
				
			});
		},
		
		inject: function (html, params) {
			
			var html = html,
				params = params;
				
			$.each(params, function (key, value) {
				
				var key = '<@' + key + '>',
					value = value ? value : '';
				
				while (html.indexOf(key) > -1) {
				
					html = html.replace(key, value);
				}	
			});
			
			return html;
			
		}
	}
	
	$.fn.grow = function (method) {
	
		if ( methods[method] ) {
			return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
		} else if ( typeof method === 'object' || ! method ) {		
			return methods.init.apply( this, arguments );
		} else {
			$.error( 'Method ' +  method + ' does not exist.' );
		}
	}
	
})(jQuery);