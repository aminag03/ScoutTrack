using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Extensions
{
    public static class QueryableExtensions
    {
        public static IQueryable<T> OrderByDynamic<T>(this IQueryable<T> source, string propertyName)
        {
            return source.OrderBy(e => EF.Property<object>(e, propertyName));
        }

        public static IQueryable<T> OrderByDescendingDynamic<T>(this IQueryable<T> source, string propertyName)
        {
            return source.OrderByDescending(e => EF.Property<object>(e, propertyName));
        }
    }
}
