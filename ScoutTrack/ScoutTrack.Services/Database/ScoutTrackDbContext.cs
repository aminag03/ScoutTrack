using Microsoft.EntityFrameworkCore;

namespace ScoutTrack.Services.Database
{
    public class ScoutTrackDbContext : DbContext
    {
        public ScoutTrackDbContext(DbContextOptions<ScoutTrackDbContext> options) : base(options)
        {
        }

        public virtual DbSet<User> Users { get; set; }
        public virtual DbSet<Badge> Badges {  get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            modelBuilder.Entity<Badge>()
                .HasIndex(b => b.Name)
                .IsUnique();

        }
    }
}
